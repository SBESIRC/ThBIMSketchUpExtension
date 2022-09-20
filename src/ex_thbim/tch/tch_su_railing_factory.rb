require 'sketchup.rb'
require_relative 'tch_su_geom_utils.rb'

module Examples
  module ThTCH2SURAILINGFACTORY
    module_function
    def to_su_railing(entities, railing, material)
      begin
        railing_build_element = railing.build_element
        railing_group = entities.add_group
        railing_face = create_railing_face(railing_group, railing_build_element)
        railing_face.reverse! if railing_face.normal.z < 0 ; # flip face to up if facing down
        railing_face.pushpull(railing_build_element.height.mm)
        railing_group.definition.add_classification("IFC 2x3", "IfcRailing")
        railing_group.material = material
        railing_group.locked = true
      rescue => e
        e.message
      end
    end

    def create_railing_face(group, build_element)
      pts = []
      build_element.outline.points.each{ |pt|
        pts.push ThTCH2SUGeomUtil.to_su_point3d(pt)
      }
      face = group.entities.add_face(pts)
    end
  end # module HelloCube
end # module Examples
