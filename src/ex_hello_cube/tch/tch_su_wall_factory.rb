require 'sketchup.rb'
require_relative 'tch_su_geom_utils.rb'

module Examples
  module ThTCH2SUWALLFACTORY
    module_function

    def to_su_wall(entities, wall)
      build_element = wall.build_element
      wall_outline = build_element.outline
      if wall_outline.points.length > 0
        group = entities.add_group
        face = create_wall_face(group, build_element)
        # If the blue face is pointing up, reverse it.
        face.reverse! if face.normal.z < 0 ; # flip face to up if facing down
        face.pushpull(build_element.height)
        transform_wall(group, build_element)
      end
    end

    def transform_wall(group, build_element)
      dir = Geom::Vector3d.new(0, 0, 1)
      origin = ThTCH2SUGeomUtil.to_su_point3d(build_element.origin)
      trans = ThTCH2SUGeomUtil.double_transformations(origin, dir)
      group.transform!(trans)
    end

    def create_wall_face(group, build_element)
      pts = []
      pts[0] = ThTCH2SUGeomUtil.to_su_point3d(build_element.outline.points[0])
      pts[1] = ThTCH2SUGeomUtil.to_su_point3d(build_element.outline.points[1])
      pts[2] = ThTCH2SUGeomUtil.to_su_point3d(build_element.outline.points[2])
      pts[3] = ThTCH2SUGeomUtil.to_su_point3d(build_element.outline.points[3])
      face = group.entities.add_face(pts)
    end
  end # module HelloCube
end # module Examples

