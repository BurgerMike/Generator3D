import Foundation
import simd

public struct G3DMesh: Sendable, Hashable {
    public var positions: [SIMD3<Float>]
    public var normals:   [SIMD3<Float>]
    public var uvs:       [SIMD2<Float>]
    public var indices:   [UInt32]      // Triángulos CCW

    public init(
        positions: [SIMD3<Float>] = [],
        normals:   [SIMD3<Float>] = [],
        uvs:       [SIMD2<Float>] = [],
        indices:   [UInt32] = []
    ) {
        self.positions = positions
        self.normals   = normals
        self.uvs       = uvs
        self.indices   = indices
    }

    public var vertexCount: Int { positions.count }
    public var indexCount:  Int { indices.count }

    /// Calcula (o recalcula) normales suavizadas promediando por vértice.
    public mutating func ensureNormals() {
        if normals.count == positions.count { return }
        normals = Self.makeSmoothNormals(positions: positions, indices: indices)
    }

    /// Asegura que haya UVs (si faltan, los rellena con (0,0)).
    public mutating func ensureUVs(default uv: SIMD2<Float> = .zero) {
        if uvs.count == positions.count { return }
        uvs = .init(repeating: uv, count: positions.count)
    }

    // MARK: - Helpers

    public static func makeSmoothNormals(
        positions: [SIMD3<Float>],
        indices: [UInt32]
    ) -> [SIMD3<Float>] {
        var nrm = Array(repeating: SIMD3<Float>(repeating: 0), count: positions.count)
        let triCount = indices.count / 3
        guard triCount > 0 else { return nrm }

        for t in 0..<triCount {
            let i0 = Int(indices[t*3 + 0])
            let i1 = Int(indices[t*3 + 1])
            let i2 = Int(indices[t*3 + 2])

            let p0 = positions[i0]
            let p1 = positions[i1]
            let p2 = positions[i2]

            let e1 = p1 - p0
            let e2 = p2 - p0
            var n  = simd_cross(e1, e2)
            let len = simd_length(n)
            if len > 0 { n /= len }  // normalizamos por triángulo

            // SÚMATE: aquí sí es += (no &+=)
            nrm[i0] += n
            nrm[i1] += n
            nrm[i2] += n
        }

        // Normaliza cada acumulado
        for i in 0..<nrm.count {
            let len = simd_length(nrm[i])
            if len > 0 {
                nrm[i] /= len
            } else {
                nrm[i] = SIMD3<Float>(0, 1, 0) // fallback
            }
        }
        return nrm
    }
}

