require 'sketchup.rb'

module Examples
    module ThProtoBufExtention
        module_function
        def to_proto_material(material)
            su_material = ThSUMaterialData.new
            su_material.material_name = material.name
            su_material.alpha = material.alpha
            su_color = material.color
            su_material.hasRGB = !su_color.nil?
            if su_material.hasRGB
                su_material.color_r = su_color.red
                su_material.color_g = su_color.green
                su_material.color_b = su_color.blue
            end
            su_material # return su_material
        end

        def to_proto_point3d(pt)
            proto_pt = ThTCHPoint3d.new
            proto_pt.x = pt.x.to_mm
            proto_pt.y = pt.y.to_mm
            proto_pt.z = pt.z.to_mm
            proto_pt
        end

        def to_proto_polygon(polygon)
            proto_polygon = ThSUPolygon.new
            proto_polygon.indices.push polygon[0]
            proto_polygon.indices.push polygon[1]
            proto_polygon.indices.push polygon[2]
            proto_polygon
        end

        def to_proto_vector3d(v)
            proto_v = ThTCHVector3d.new
            proto_v.x = v.x
            proto_v.y = v.y
            proto_v.z = v.z
            proto_v
        end

        def to_proto_transformation(m)
            arr = m.to_a
            proto_matrix = ThTCHMatrix3d.new
            proto_matrix.data11 = arr[0]
            proto_matrix.data12 = arr[1]
            proto_matrix.data13 = arr[2]
            proto_matrix.data14 = arr[3]
      
            proto_matrix.data21 = arr[4]
            proto_matrix.data22 = arr[5]
            proto_matrix.data23 = arr[6]
            proto_matrix.data24 = arr[7]
      
            proto_matrix.data31 = arr[8]
            proto_matrix.data32 = arr[9]
            proto_matrix.data33 = arr[10]
            proto_matrix.data34 = arr[11]
      
            proto_matrix.data41 = arr[12].to_mm
            proto_matrix.data42 = arr[13].to_mm
            proto_matrix.data43 = arr[14].to_mm
            proto_matrix.data44 = arr[15]
      
            proto_matrix
        end

        def to_ptoto_comp_definition_data(comp_def)
            su_component_definition = ThSUCompDefinitionData.new
            su_component_definition.definition_name = comp_def.name
            tr = Geom::Transformation.new
            to_proto_comp_definition_face_data(su_component_definition.faces, comp_def, tr)
            su_component_definition
        end

        def to_proto_comp_definition_face_data(face_collection, comp_def, tr)
            comp_def_instance = comp_def.entities.grep(Sketchup::ComponentInstance)
            if comp_def_instance.length > 0
                comp_def_instance.each{ |ent_instance|
                    to_proto_comp_definition_face_data(face_collection, ent_instance.definition, tr * ent_instance.transformation)
                }
            else
                faces = comp_def.entities.grep(Sketchup::Face)
                faces.each{ |face|
                    # 0: Include PolygonMeshPoints,
                    # 1: Include PolygonMeshUVQFront,
                    # 2: Include PolygonMeshUVQBack,
                    # 4: Include PolygonMeshNormals.
                    su_face_data = ThSUFaceData.new
                    mesh = face.mesh(4)
                    su_face_data.face_normal = ThProtoBufExtention.to_proto_vector3d(mesh.normal_at(1))
                    su_mesh = ThSUPolygonMesh.new
                    mesh.points.each{ |pt|
                        su_mesh.points.push ThProtoBufExtention.to_proto_point3d(tr * pt)
                    }
                    mesh.polygons.each{ |polygon|
                        su_mesh.polygons.push ThProtoBufExtention.to_proto_polygon(polygon)
                    }
                    su_face_data.mesh = su_mesh
                    material = face.material
                    if !material.nil?
                        su_material = ThProtoBufExtention.to_proto_material(material)
                        su_face_data.material = su_material
                    end
                    face_collection.push su_face_data
                }
            end
        end

        def su_project_add_definition(su_project, su_definition)
            su_project.definitions.push su_definition
            return su_project.definitions.length - 1
        end

        def to_proto_component_data(ent, su_component_definition_index)
            su_component_data = ThSUBuildingElementData.new
            su_component_instance = ThSUComponentData.new
            su_component_instance.definition_index = su_component_definition_index
            su_component_instance.transformations = ThProtoBufExtention.to_proto_transformation(ent.transformation)
            material = ent.material
            if !material.nil?
                su_material = ThProtoBufExtention.to_proto_material(material)
                su_component_instance.material = su_material
            end
            su_component_data.component = su_component_instance
            su_component_data.root = ThTCHRootData.new
            su_component_data.root.globalId = ent.entityID.to_s
            su_component_data.root.name = ent.name.to_s
            su_component_data
        end

    end # module ThProtoBufExtention
end # module Examples