//
//  Extrude.swift
//  Generator3D
//
//  Created by Miguel Carlos Elizondo Mrtinez on 17/10/25.
//

import Foundation
import simd

public enum G3DExtrude {
    public static func convexPolygon(_ poly: [SIMD2<Float>], height h: Float, cap: Bool = true) -> G3DMesh {
        precondition(poly.count >= 3, "Polígono inválido")
        let n = poly.count
        var positions: [SIMD3<Float>] = []
        var uvs:       [SIMD2<Float>] = []
        var indices:   [UInt32] = []

        // Lateral (doble anillo: y=0 y y=h)
        for ring in 0...1 {
            let y = ring == 0 ? 0.0 as Float : h
            for p in poly {
                positions.append([p.x, y, p.y])
                // UVs sencillos: u = arco/longitud, v = y/h
                uvs.append([p.x, y/h]) // placeholder simple
            }
        }

        // Triangulado lateral
        for i in 0..<n {
            let i0 = UInt32(i)
            let i1 = UInt32((i+1) % n)
            let i2 = UInt32(i + n)
            let i3 = UInt32((i+1) % n + n)
            // Quad: i0,i2,i1  y  i1,i2,i3   (CCW desde afuera)
            indices += [i0, i2, i1,  i1, i2, i3]
        }

        if cap {
            // Tapa superior (y=h) – fan
            let topBase = UInt32(n) // anillo superior inicia en n
            for i in 1..<(n-1) {
                indices += [topBase + 0, topBase + UInt32(i), topBase + UInt32(i+1)]
            }
            // Tapa inferior (y=0) – fan invertido
            for i in 1..<(n-1) {
                indices += [0, UInt32(i+1), UInt32(i)]
            }
        }

        var mesh = G3DMesh(positions: positions, normals: [], uvs: uvs, indices: indices)
        mesh.ensureNormals()
        mesh.ensureUVs()
        return mesh
    }
}
