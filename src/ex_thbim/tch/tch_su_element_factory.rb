require 'sketchup.rb'
require_relative 'tch_su_geom_utils.rb'

module Examples
  module ThTCH2SUELEMENTFACTORY
    module_function

    def to_su_element(entities, definition, transform)
      begin
        element_group = entities.add_group
        # definition.brep_faces.each{ |face|
        #   outer_loop = ThTCH2SUGeomUtil.to_su_pts(face.outer_loop)
        #   element_group.entities.add_face(outer_loop)
        #   face.inner_loops.each{ |lp|
        #     f = element_group.entities.add_face(ThTCH2SUGeomUtil.to_su_pts(lp))
        #     element_group.entities.erase_entities f
        #   }
        # }
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

        # element_group.transformation = ThTCH2SUGeomUtil.to_su_transformation(transform)
        element_group.name = "Platform3D构建"
        element_group.locked = true
      rescue => exception
        msg = exception.message
      end
    end
  end # module HelloCube
end # module Examples

