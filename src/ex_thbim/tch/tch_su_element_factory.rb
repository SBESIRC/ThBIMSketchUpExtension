require 'sketchup.rb'
require_relative 'tch_su_geom_utils.rb'

module Examples
  module ThTCH2SUELEMENTFACTORY
    module_function

    def to_su_element(entities, definition, transform)
      begin
        element_group = entities.add_group
        definition.brep_faces.each{ |face|
          outer_loop = ThTCH2SUGeomUtil.to_su_pts(face.outer_loop)
          element_group.entities.add_face(outer_loop)
          face.inner_loops.each{ |lp|
            f = element_group.entities.add_face(ThTCH2SUGeomUtil.to_su_pts(lp))
            element_group.entities.erase_entities f
          }
        }
        element_group.transformation = ThTCH2SUGeomUtil.to_su_transformation(transform)
        element_group.name = "Platform3D构建"
        element_group.locked = true
      rescue => exception
        msg = exception.message
      end
    end
  end # module HelloCube
end # module Examples

