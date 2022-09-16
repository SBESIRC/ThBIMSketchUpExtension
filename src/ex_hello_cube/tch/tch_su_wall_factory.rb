require 'sketchup.rb'
require_relative 'tch_su_geom_utils.rb'

module Examples
  module ThTCH2SUWALLFACTORY
    module_function

    def to_su_wall(entities, wall, wall_material, door_material, window_material)
      wall_build_element = wall.build_element
      wall_group = entities.add_group
      wall_face = create_wall_face(wall_group, wall_build_element)
      # If the blue face is pointing up, reverse it.
      wall_face.reverse! if wall_face.normal.z < 0 ; # flip face to up if facing down
      wall_face.pushpull(wall_build_element.height.mm)
      
      doors = wall.doors
      doors.each{ |door|
        door_build_element = door.build_element
        door_hole_group = entities.add_group
        door_hole_face = create_opening_hole_face(door_hole_group, door_build_element, wall_build_element.width)
        # If the blue face is pointing up, reverse it.
        door_hole_face.reverse! if door_hole_face.normal.z < 0 ; # flip face to up if facing down
        door_hole_face.pushpull(door_build_element.height.mm)
        # 把墙挖洞
        wall_group = door_hole_group.subtract(wall_group)

        door_group = entities.add_group
        door_face = create_opening_face(door_group, door_build_element)
        # If the blue face is pointing up, reverse it.
        door_face.reverse! if door_face.normal.z < 0 ; # flip face to up if facing down
        door_face.pushpull(door_build_element.height.mm)
        door_group.definition.add_classification("IFC 2x3", "IfcDoor")
        door_group.material = door_material
        door_group.locked = true
      }

      windows = wall.windows
      windows.each{ |window|
        window_build_element = window.build_element

        window_hole_group = entities.add_group
        window_hole_face = create_opening_hole_face(window_hole_group, window_build_element, wall_build_element.width)
        # If the blue face is pointing up, reverse it.
        window_hole_face.reverse! if window_hole_face.normal.z < 0 ; # flip face to up if facing down
        window_hole_face.pushpull(window_build_element.height.mm)
        # 把墙挖洞
        wall_group = window_hole_group.subtract(wall_group)

        window_group = entities.add_group
        window_face = create_opening_face(window_group, window_build_element)
        # If the blue face is pointing up, reverse it.
        window_face.reverse! if window_face.normal.z < 0 ; # flip face to up if facing down
        window_face.pushpull(window_build_element.height.mm)
        window_group.definition.add_classification("IFC 2x3", "IfcWindow")
        window_group.material = window_material
        window_group.locked = true
      }
      wall_group.definition.add_classification("IFC 2x3", "IfcWall")
      wall_group.name = "墙"
      wall_group.material = wall_material
      wall_group.locked = true
      transform_wall(wall_group, wall_build_element)
    end

    def transform_wall(group, build_element)
      dir = Geom::Vector3d.new(0, 0, 1)
      origin = ThTCH2SUGeomUtil.to_su_point3d(build_element.origin)
      trans = ThTCH2SUGeomUtil.double_transformations(origin, dir)
      group.transform!(trans)
    end

    def create_wall_face(group, build_element)
      pts = []
      build_element.outline.points.each{ |pt|
        pts.push ThTCH2SUGeomUtil.to_su_point3d(pt)
      }
      face = group.entities.add_face(pts)
    end

    def create_opening_face(group, build_element)
      x_vector = ThTCH2SUGeomUtil.to_su_vector3d(build_element.x_vector)
      y_vector = x_vector.cross(Geom::Vector3d.new(0, 0, 1))
      origin = ThTCH2SUGeomUtil.to_su_point3d(build_element.origin)
      pts = []
      pts[0] = origin.offset(x_vector, (build_element.length / 2).mm).offset(y_vector, (build_element.width / 2).mm)
      pts[1] = origin.offset(x_vector, (build_element.length / 2).mm).offset(y_vector, (-1 * build_element.width / 2).mm)
      pts[2] = origin.offset(x_vector, (-1 * build_element.length / 2).mm).offset(y_vector, (-1 * build_element.width / 2).mm)
      pts[3] = origin.offset(x_vector, (-1 * build_element.length / 2).mm).offset(y_vector, (build_element.width / 2).mm)
      opening_face = group.entities.add_face(pts)
    end

    def create_opening_hole_face(group, build_element, wall_width)
      x_vector = ThTCH2SUGeomUtil.to_su_vector3d(build_element.x_vector)
      y_vector = x_vector.cross(Geom::Vector3d.new(0, 0, 1))
      origin = ThTCH2SUGeomUtil.to_su_point3d(build_element.origin)
      pts = []
      pts[0] = origin.offset(x_vector, (build_element.length / 2).mm).offset(y_vector, (wall_width + 5 / 2).mm)
      pts[1] = origin.offset(x_vector, (build_element.length / 2).mm).offset(y_vector, (-1 * wall_width + 5 / 2).mm)
      pts[2] = origin.offset(x_vector, (-1 * build_element.length / 2).mm).offset(y_vector, (-1 * wall_width + 5 / 2).mm)
      pts[3] = origin.offset(x_vector, (-1 * build_element.length / 2).mm).offset(y_vector, (wall_width + 5 / 2).mm)
      hole_face = group.entities.add_face(pts)
    end

  end # module HelloCube
end # module Examples

