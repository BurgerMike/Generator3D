
import Metal
import simd
import Foundation
import Generator3D

public struct G3DMetalBuffers {
    public let vbPositions: MTLBuffer
    public let vbNormals:   MTLBuffer
    public let vbUVs:       MTLBuffer
    public let ib:          MTLBuffer
    public let indexCount:  Int
    public let indexType:   MTLIndexType
}

public enum G3DMetalBridge {
    public static func makeBuffers(device: MTLDevice, mesh: G3DMesh) throws -> G3DMetalBuffers {
        precondition(!mesh.positions.isEmpty && !mesh.indices.isEmpty, "Malla vacía")

        var m = mesh
        m.ensureNormals()
        m.ensureUVs()

        func make<T>(_ array: [T], opts: MTLResourceOptions = []) -> MTLBuffer {
            let length = array.count * MemoryLayout<T>.stride
            guard let b = device.makeBuffer(bytes: array, length: length, options: opts) else {
                fatalError("No se pudo crear buffer")
            }
            return b
        }

        let vbPos = make(m.positions)
        let vbNrm = make(m.normals)
        let vbUV  = make(m.uvs)

        let maxIndex = m.indices.max() ?? 0
        let use16 = maxIndex < UInt32(UInt16.max)
        let indexType: MTLIndexType = use16 ? .uint16 : .uint32

        let ib: MTLBuffer
        if use16 {
            ib = make(m.indices.map(UInt16.init))
        } else {
            ib = make(m.indices)
        }

        return .init(vbPositions: vbPos, vbNormals: vbNrm, vbUVs: vbUV, ib: ib,
                     indexCount: m.indexCount, indexType: indexType)
    }
}


