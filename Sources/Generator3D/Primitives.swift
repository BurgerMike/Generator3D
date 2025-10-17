//
//  Primitives.swift
//  Generator3D
//
//  Created by Miguel Carlos Elizondo Mrtinez on 17/10/25.
//

import Foundation
import simd

public enum G3D {
    // Caja centrada en el origen
    public static func box(size: SIMD3<Float>) -> G3DMesh {
        let sx = size.x * 0.5, sy = size.y * 0.5, sz = size.z * 0.5
        let P: [SIMD3<Float>] = [
            [-sx,-sy,-sz], [ sx,-sy,-sz], [ sx, sy,-sz], [-sx, sy,-sz], // back z-
            [-sx,-sy, sz], [ sx,-sy, sz], [ sx, sy, sz], [-sx, sy, sz], // front z+
        ]
        var mesh = G3DMesh(
            positions: [
                // back
                P[0], P[1], P[2], P[3],
                // front
                P[5], P[4], P[7], P[6],
                // left
                P[4], P[0], P[3], P[7],
                // right
                P[1], P[5], P[6], P[2],
                // bottom
                P[4], P[5], P[1], P[0],
                // top
                P[3], P[2], P[6], P[7]
            ],
            uvs: Array(repeating: .zero, count: 24),
            indices: [
                0,1,2, 0,2,3,    4,5,6, 4,6,7,
                8,9,10, 8,10,11, 12,13,14, 12,14,15,
                16,17,18, 16,18,19, 20,21,22, 20,22,23
            ]
        )
        mesh.ensureNormals()
        mesh.ensureUVs()
        return mesh
    }

    // Esfera UV (latitud/longitud)
    public static func sphere(radius r: Float, latSegments: Int = 24, lonSegments: Int = 36) -> G3DMesh {
        precondition(latSegments >= 3 && lonSegments >= 3, "Segmentos insuficientes")
        var positions: [SIMD3<Float>] = []
        var normals:   [SIMD3<Float>] = []
        var uvs:       [SIMD2<Float>] = []
        var indices:   [UInt32] = []

        for y in 0...latSegments {
            let v = Float(y) / Float(latSegments)
            let theta = v * .pi
            let ct = cos(theta), st = sin(theta)

            for x in 0...lonSegments {
                let u = Float(x) / Float(lonSegments)
                let phi = u * 2 * .pi
                let cp = cos(phi), sp = sin(phi)

                let n = SIMD3<Float>(cp*st, ct, sp*st)
                positions.append(n * r)
                normals.append(n)
                uvs.append([u, 1 - v])
            }
        }

        let row = lonSegments + 1
        for y in 0..<latSegments {
            for x in 0..<lonSegments {
                let i0 = UInt32(y*row + x)
                let i1 = UInt32(i0 + 1)
                let i2 = UInt32(i0 + UInt32(row))
                let i3 = UInt32(i2 + 1)
                indices += [i0, i2, i1, i1, i2, i3]
            }
        }

        return G3DMesh(positions: positions, normals: normals, uvs: uvs, indices: indices)
    }

    // Cilindro eje Y, centrado en el origen
    public static func cylinder(radius r: Float, height h: Float,
                                radialSegments: Int = 32,
                                heightSegments: Int = 1,
                                capped: Bool = true) -> G3DMesh {
        precondition(radialSegments >= 3 && heightSegments >= 1)
        var positions: [SIMD3<Float>] = []
        var normals:   [SIMD3<Float>] = []
        var uvs:       [SIMD2<Float>] = []
        var indices:   [UInt32] = []

        let halfH = h * 0.5
        // Lateral
        for y in 0...heightSegments {
            let v = Float(y) / Float(heightSegments)
            let py = simd_mix(-halfH, halfH, v)
            for i in 0...radialSegments {
                let u = Float(i) / Float(radialSegments)
                let ang = u * 2 * .pi
                let c = cos(ang), s = sin(ang)
                let n = SIMD3<Float>(c, 0, s)
                positions.append([n.x * r, py, n.z * r])
                normals.append(n)
                uvs.append([u, v])
            }
        }
        let row = radialSegments + 1
        for y in 0..<heightSegments {
            for i in 0..<radialSegments {
                let i0 = UInt32(y*row + i)
                let i1 = UInt32(i0 + 1)
                let i2 = UInt32(i0 + UInt32(row))
                let i3 = UInt32(i2 + 1)
                indices += [i0, i2, i1, i1, i2, i3]
            }
        }

        // Tapas
        if capped {
            // top (y = +halfH)
            let topCenterIndex = UInt32(positions.count)
            positions.append([0, halfH, 0]); normals.append([0,1,0]); uvs.append([0.5,0.5])
            for i in 0...radialSegments {
                let u = Float(i) / Float(radialSegments)
                let ang = u * 2 * .pi
                let c = cos(ang), s = sin(ang)
                positions.append([c*r, halfH, s*r])
                normals.append([0,1,0])
                uvs.append([ (c+1)*0.5, (s+1)*0.5 ])
            }
            for i in 1...radialSegments {
                indices += [topCenterIndex, topCenterIndex + UInt32(i), topCenterIndex + UInt32(i+1)]
            }

            // bottom (y = -halfH)
            let botCenterIndex = UInt32(positions.count)
            positions.append([0, -halfH, 0]); normals.append([0,-1,0]); uvs.append([0.5,0.5])
            for i in 0...radialSegments {
                let u = Float(i) / Float(radialSegments)
                let ang = u * 2 * .pi
                let c = cos(ang), s = sin(ang)
                positions.append([c*r, -halfH, s*r])
                normals.append([0,-1,0])
                uvs.append([ (c+1)*0.5, (s+1)*0.5 ])
            }
            for i in 1...radialSegments {
                // sentido CCW visto desde abajo: invertimos
                indices += [botCenterIndex, botCenterIndex + UInt32(i+1), botCenterIndex + UInt32(i)]
            }
        }

        return G3DMesh(positions: positions, normals: normals, uvs: uvs, indices: indices)
    }
}
