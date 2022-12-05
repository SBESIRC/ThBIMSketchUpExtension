require 'sketchup.rb'
Sketchup.require 'tch_su_geom_utils'
Sketchup.require 'global_config'

module ThBM
  module ThTCH2SUELEMENTFACTORY
    module_function
    def to_su_element(entities, definition, element)
      begin
        element_group = entities.add_group
        definition.mesh_faces.each{ |face|
          mesh = Geom::PolygonMesh.new()
          indicies = []
          face.mesh.points.each{ |pt|
            indicies << mesh.add_point(ThTCH2SUGeomUtil.to_su_point3d(pt))
          }
          face.mesh.polygons.each{ |triangle|
            polygon = triangle.indices.map { |i| indicies[i] }
            mesh.add_polygon(polygon)
          }
          result = element_group.entities.add_faces_from_mesh(mesh, Geom::PolygonMesh::NO_SMOOTH_OR_HIDE)
        }
        unless element.component.ifc_classification.nil?
          case element.component.ifc_classification
          when "IfcWall"
            element_group.definition.add_classification("IFC 2x3", "IfcWall")
            element_group.material = GlobalConfiguration.material_wall
          when "IfcWindow"
            element_group.definition.add_classification("IFC 2x3", "IfcWindow")
            element_group.material = GlobalConfiguration.material_window
          when "IfcDoor"
            element_group.definition.add_classification("IFC 2x3", "IfcDoor")
            element_group.material = GlobalConfiguration.material_door
          when "IfcBeam"
            element_group.definition.add_classification("IFC 2x3", "IfcBeam")
            element_group.material = GlobalConfiguration.material_beam
          when "IfcColumn"
            element_group.definition.add_classification("IFC 2x3", "IfcColumn")
            element_group.material = GlobalConfiguration.material_column
          when "IfcSlab"
            element_group.definition.add_classification("IFC 2x3", "IfcSlab")
            element_group.material = GlobalConfiguration.material_slab
          when "IfcRailing"
            element_group.definition.add_classification("IFC 2x3", "IfcRailing")
            element_group.material = GlobalConfiguration.material_railing
          end
        end
        element_group.entities.grep(Sketchup::Edge).each{ |e|
          faces = e.faces
          if faces.length > 1
            normal = faces.first.normal
            faces.delete_if{ |face| face.normal.samedirection?(normal) }
            if faces.length == 0
              e.visible = false
            end
          else
            e.visible = false
          end
        }
        element_group.name = "Platform3D构建"
        element_group.locked = true
      rescue => exception
        msg = exception.message
      end
    end
  end # module HelloCube
end # module ThBM

