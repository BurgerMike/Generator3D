//
//  Lathe.swift
//  Generator3D
//
//  Created by Miguel Carlos Elizondo Mrtinez on 17/10/25.
//

import Foundation
import simd

public enum G3DLathe {
    /// `profile`: puntos (x,y) con x >= 0, CCW; `segments`: resol. angular
    public static func revolve(profile: [SIMD2<Float>], segments: Int = 48, capEnds: Bool = true) -> G3DMesh {
        precondition(profile.count >= 2 && segments >= 3)
        let n = profile.count
        var positions: [SIMD3<Float>] = []
        var uvs:       [SIMD2<Float>] = []
        var indices:   [UInt32] = []

        for s in 0...segments {
            let u  = Float(s) / Float(segments)
            let ang = u * 2 * .pi
            let c = cos(ang), z = sin(ang)
            for (i, p) in profile.enumerated() {
                let pos = SIMD3<Float>(p.x * c, p.y, p.x * z)
                positions.append(pos)
                uvs.append([u, Float(i)/Float(n-1)])
            }
        }

        let row = n
        for s in 0..<segments {
            let base = s * row
            for i in 0..<(n-1) {
                let i0 = UInt32(base + i)
                let i1 = UInt32(base + i + 1)
                let i2 = UInt32(base + i + row)
                let i3 = UInt32(base + i + row + 1)
                indices += [i0, i2, i1, i1, i2, i3]
            }
        }

        var mesh = G3DMesh(positions: positions, normals: [], uvs: uvs, indices: indices)
        mesh.ensureNormals()
        mesh.ensureUVs()
        return mesh
    }
}
