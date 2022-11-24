require 'sketchup.rb'

module ThBM
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
            proto_pt.x = pt.x.to_mm.round(5)
            proto_pt.y = pt.y.to_mm.round(5)
            proto_pt.z = pt.z.to_mm.round(5)
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
            proto_v.x = v.x.to_mm.round(5)
            proto_v.y = v.y.to_mm.round(5)
            proto_v.z = v.z.to_mm.round(5)
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
      
            proto_matrix.data41 = arr[12].to_mm.round(5)
            proto_matrix.data42 = arr[13].to_mm.round(5)
            proto_matrix.data43 = arr[14].to_mm.round(5)
            proto_matrix.data44 = arr[15]
      
            proto_matrix
        end

        def to_proto_definition_data(su_project, ent, tr, hashcode)
            definition = ent.definition
            su_component_definition = ThSUCompDefinitionData.new
            if definition.name != "Laura" and !definition.name.include?("ThDefinition")
                su_definition_index = su_project.definitions.index{ |d| d.definition_name == definition.name}
                minz = 1.0e8
                maxz = -1.0e8
                definition.entities.each{ |e|
                    if e.is_a?(Sketchup::Face)
                        if su_definition_index.nil?
                            su_face_data = ThSUFaceBrepData.new
                            e.loops.each{ |su_loop|
                                if su_loop.outer?
                                    su_face_data.outer_loop = to_proto_loop_data(su_loop)
                                else
                                    su_face_data.inner_loops.push to_proto_loop_data(su_loop)
                                end
                            }
                            su_component_definition.brep_faces.push su_face_data
                        end
                        centerpt_z = (tr * e.bounds.center).z.to_mm
                        minz = [minz, centerpt_z].min
                        maxz = [maxz, centerpt_z].max
                    elsif e.is_a?(Sketchup::Group) or e.is_a?(Sketchup::ComponentInstance)
                        to_proto_definition_data(su_project, e, tr * e.transformation, get_hash_code(hashcode, e.entityID))
                    end
                }
                if su_component_definition.brep_faces.length > 0
                    su_component_definition.definition_name = definition.name
                    su_definition_index = su_project_add_definition(su_project, su_component_definition)
                end
                if !su_definition_index.nil?
                    su_component_data = to_su_component_data(ent, tr, su_definition_index, hashcode)
                    ifc_type = definition.get_attribute("AppliedSchemaTypes", "IFC 2x3")
                    if !ifc_type.nil?
                        su_component_data.component.ifc_classification = ifc_type
                    end

                    if su_project.building.storeys.length == 1 and su_project.building.storeys.first.stdFlr_no == -100
                        first_storey = su_project.building.storeys.first
                        first_storey.buildings.push su_component_data
                        first_storey.elevation = [first_storey.elevation, minz].min
                        first_storey.height = [first_storey.height, maxz - first_storey.elevation].max
                    else
                        storey_index = su_project.building.storeys.rindex{ |o| minz > o.elevation - 20}
                        if storey_index.nil?
                            first_storey = su_project.building.storeys.first
                            if first_storey.stdFlr_no == -100
                                first_storey.buildings.push su_component_data
                                first_storey.elevation = [first_storey.elevation, minz].min
                            else
                                storey_data = ThSUBuildingStoreyData.new
                                storey_data.root = ThTCHRootData.new
                                storey_data.number = su_project.building.storeys.first.number - 1
                                storey_data.elevation = minz
                                storey_data.height = 0
                                storey_data.stdFlr_no = -100
                                if storey_data.number == 0
                                    storey_data.number = -1
                                end
                                storey_data.root.globalId = "su_storey_" + storey_data.number.to_s
                                storey_data.buildings.push su_component_data
                                su_project.building.storeys.insert(0, storey_data)
                            end
                        else
                            storey = su_project.building.storeys[storey_index]
                            if storey.stdFlr_no == -100
                                storey.buildings.push su_component_data
                                storey.height = [storey.height, maxz - storey.elevation].max
                            elsif storey.elevation + storey.height - 20 < minz
                                storey_data = ThSUBuildingStoreyData.new
                                storey_data.root = ThTCHRootData.new
                                storey_data.number = su_project.building.storeys.last.number + 1
                                storey_data.elevation = storey.elevation + storey.height
                                storey_data.height = maxz - storey_data.elevation
                                storey_data.stdFlr_no = -100
                                storey_data.root.globalId = "su_storey_" + storey_data.number.to_s
                                storey_data.buildings.push su_component_data
                                su_project.building.storeys.push storey_data
                            else
                                storey.buildings.push su_component_data
                            end
                        end
                    end
                end
            end
        end

        def su_project_add_definition(su_project, su_definition)
            su_project.definitions.push su_definition
            return su_project.definitions.length - 1
        end

        def to_su_component_data(ent, tr, su_component_definition_index, hashcode)
            su_component_data = ThSUBuildingElementData.new
            su_component_data.root = ThTCHRootData.new
            su_component_data.root.globalId = hashcode.to_s
            su_component_data.root.name = ent.name.to_s
            su_component_data.component = ThSUComponentData.new
            su_component_data.component.transformations = ThProtoBufExtention.to_proto_transformation(tr)
            su_component_data.component.definition_index = su_component_definition_index
            if !(ent_layer = ent.layer).nil?
                case ent_layer.name
                when "S_BEAM"
                    su_component_data.component.ifc_classification = "IfcBeam"
                    ent_name = ent.name
                    if !ent_name.nil?
                        su_component_data.component.instance_name = ent_name
                    end
                when "S_COLU"
                    su_component_data.component.ifc_classification = "IfcColumn"
                when "S_FLOOR", "S_SLAB"
                    su_component_data.component.ifc_classification = "IfcSlab"
                when "S_WALL"
                    su_component_data.component.ifc_classification = "IfcWall"
                when "S_CONS_构造柱"
                    su_component_data.component.ifc_classification = "IfcColumn"
                    su_component_data.component.instance_name = "S_CONS_构造柱"
                when "S_CONS_通高墙"
                    su_component_data.component.ifc_classification = "IfcWall"
                    su_component_data.component.instance_name = "S_CONS_通高墙"
                when "S_CONS_窗台墙"
                    su_component_data.component.ifc_classification = "IfcWall"
                    su_component_data.component.instance_name = "S_CONS_窗台墙"
                when "S_COLU_梯柱"
                    su_component_data.component.ifc_classification = "IfcColumn"
                    su_component_data.component.instance_name = "S_COLU_梯柱"
                when "S_BEAM_梯梁"
                    su_component_data.component.ifc_classification = "IfcBeam"
                    ent_name = ent.name
                    if !ent_name.nil?
                        su_component_data.component.instance_name = ent_name + ";S_BEAM_梯梁"
                    else
                        su_component_data.component.instance_name = "S_BEAM_梯梁"
                    end
                end
            end
            su_component_data
        end

        def to_proto_loop_data(su_loop)
            su_loop_data = ThSULoopData.new
            su_loop.vertices.each{ |v|
                su_loop_data.points.push to_proto_point3d(v.position)
            }
            su_loop_data
        end

        def get_hash_code(hash, code)
            hash * 16777619 ^ code
        end

    end # module ThProtoBufExtention
end # module ThBM