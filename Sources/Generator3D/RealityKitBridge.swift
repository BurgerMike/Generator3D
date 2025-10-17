
import Foundation
import simd
import RealityKit
import Generator3D

public enum G3DRealityKitBridgeError: Error { case emptyMesh }

public enum G3DRealityKitBridge {

    /// Crea un MeshResource desde tu malla. (No requiere MainActor)
    public static func makeMeshResource(from mesh: G3DMesh) throws -> MeshResource {
        guard !mesh.positions.isEmpty, !mesh.indices.isEmpty else {
            throw G3DRealityKitBridgeError.emptyMesh
        }
        var m = mesh
        if m.normals.count != m.positions.count { m.ensureNormals() }
        if m.uvs.count     != m.positions.count { m.ensureUVs() }

        var d = MeshDescriptor(name: "g3d")
        d.positions          = .init(m.positions)
        d.normals            = .init(m.normals)
        d.textureCoordinates = .init(m.uvs)
        d.primitives         = .triangles(m.indices)

        return try MeshResource.generate(from: [d])
    }

    /// Material por defecto estable, sin dependencias de UIKit/AppKit.
    @MainActor
    public static func defaultMaterial() -> Material {
        // RealityKit 2+ soporta Material.Color con RGBA en [0,1]
        let color = Material.Color(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0)
        // Usa el init directo (evita baseColor/tint)
        return SimpleMaterial(color: color, roughness: 0.6, isMetallic: false)
    }

    /// Crea una ModelEntity (MainActor requerido por RealityKit).
    @MainActor
    public static func makeModelEntity(from mesh: G3DMesh,
                                       material: Material? = nil) throws -> ModelEntity {
        let mr  = try makeMeshResource(from: mesh)
        let mat = material ?? defaultMaterial()
        return ModelEntity(mesh: mr, materials: [mat])
    }

    /// Opcional: fusiona varias mallas en un solo MeshResource.
    public static func makeMeshResource(merging meshes: [G3DMesh]) throws -> MeshResource {
        precondition(!meshes.isEmpty, "Lista de mallas vacía")
        var descriptors: [MeshDescriptor] = []
        descriptors.reserveCapacity(meshes.count)

        for (k, base) in meshes.enumerated() {
            var m = base
            if m.normals.count != m.positions.count { m.ensureNormals() }
            if m.uvs.count     != m.positions.count { m.ensureUVs() }

            var d = MeshDescriptor(name: "g3d-\(k)")
            d.positions          = .init(m.positions)
            d.normals            = .init(m.normals)
            d.textureCoordinates = .init(m.uvs)
            d.primitives         = .triangles(m.indices)
            descriptors.append(d)
        }
        return try MeshResource.generate(from: descriptors)
    }
}

public extension G3DMesh {
    /// Azúcar: malla → ModelEntity (MainActor)
    @MainActor
    func toModelEntity(material: Material? = nil) throws -> ModelEntity {
        try G3DRealityKitBridge.makeModelEntity(from: self, material: material)
    }

    /// Azúcar: malla → MeshResource
    func toRealityKitMeshResource() throws -> MeshResource {
        try G3DRealityKitBridge.makeMeshResource(from: self)
    }
}


