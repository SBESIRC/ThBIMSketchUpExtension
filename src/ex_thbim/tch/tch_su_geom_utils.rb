require 'sketchup.rb'
# require 'ThTCH2SUGeomUtil'

module ThBM
  module ThTCH2SUGeomUtil
    module_function

    def to_su_point3d(pt)
      Geom::Point3d.new(pt.x.mm, pt.y.mm, pt.z.mm)
    end

    def to_su_vector3d(v)
      Geom::Vector3d.new(v.x, v.y, v.z)
    end

    def to_su_transformation(m)
      arr = [
        m.data11, m.data12, m.data13, m.data14,
        m.data21, m.data22, m.data23, m.data24,
        m.data31, m.data32, m.data33, m.data34,
        m.data41, m.data42, m.data43, m.data44,
      ]
      Geom::Transformation.new(arr)
    end

    def to_su_pts(lp)
      loop_array = []
      lp.points.each{ |pt|
        loop_array.push to_su_point3d(pt)
      }
      loop_array
    end

    def to_su_face(group, polyline)
      edges = []
      points = polyline.points
      polyline.segments.each{ |segment|
        if segment.index.length == 2
          edges.push to_su_line_edge(group, points[segment.index[0]], points[segment.index[1]])
        else
          edges = edges + to_su_curve_edge(group, points[segment.index[0]], points[segment.index[1]], points[segment.index[2]])
        end
      }
      face = group.entities.add_face(edges)
    end

    def to_su_edge_3pt(pt1, pt2, pt3)
      x1 = pt1.x.mm
      x2 = pt2.x.mm
      x3 = pt3.x.mm

      y1 = pt1.y.mm
      y2 = pt2.y.mm
      y3 = pt3.y.mm

      z1 = pt1.z.mm
      z2 = pt2.z.mm
      z3 = pt3.z.mm

      a1 = (y1*z2 - y2*z1 - y1*z3 + y3*z1 + y2*z3 - y3*z2)
      b1 = -(x1*z2 - x2*z1 - x1*z3 + x3*z1 + x2*z3 - x3*z2)
      c1 = (x1*y2 - x2*y1 - x1*y3 + x3*y1 + x2*y3 - x3*y2)
      d1 = -(x1*y2*z3 - x1*y3*z2 - x2*y1*z3 + x2*y3*z1 + x3*y1*z2 - x3*y2*z1)

      a2 = 2 * (x2 - x1)
      b2 = 2 * (y2 - y1)
      c2 = 2 * (z2 - z1)
      d2 = x1*x1 + y1*y1 + z1*z1 - x2*x2 - y2*y2 - z2*z2

      a3 = 2 * (x3 - x1)
      b3 = 2 * (y3 - y1)
      c3 = 2 * (z3 - z1)
      d3 = x1*x1 + y1*y1 + z1*z1 - x3*x3 - y3*y3 - z3*z3

      cx = -(b1*c2*d3 - b1*c3*d2 - b2*c1*d3 + b2*c3*d1 + b3*c1*d2 - b3*c2*d1)/(a1*b2*c3 - a1*b3*c2 - a2*b1*c3 + a2*b3*c1 + a3*b1*c2 - a3*b2*c1)
      cy =  (a1*c2*d3 - a1*c3*d2 - a2*c1*d3 + a2*c3*d1 + a3*c1*d2 - a3*c2*d1)/(a1*b2*c3 - a1*b3*c2 - a2*b1*c3 + a2*b3*c1 + a3*b1*c2 - a3*b2*c1)
      cz = -(a1*b2*d3 - a1*b3*d2 - a2*b1*d3 + a2*b3*d1 + a3*b1*d2 - a3*b2*d1)/(a1*b2*c3 - a1*b3*c2 - a2*b1*c3 + a2*b3*c1 + a3*b1*c2 - a3*b2*c1)
      r = Math.sqrt((cx - x1) ** 2 + (cy - y1) ** 2 + (cz - z1) ** 2)

      model = Sketchup.active_model
      entities = model.active_entities
      center_point = Geom::Point3d.new(cx, cy, cz)
      # Create a circle perpendicular to the provided vector.
      normal = Z_AXIS
      xaxis = X_AXIS
      # edges = entities.add_circle(center_point, normal, r)
      pt11 = Geom::Point3d.new(x1, y1, z1)
      pt21 = Geom::Point3d.new(x3, y3, z3)
      vector1 = pt11 - center_point
      vector2 = pt21 - center_point
      angle1 = (vector1.angle_between xaxis).radians
      angle2 = (vector2.angle_between xaxis).radians
      edges2 = entities.add_arc(center_point, xaxis, normal, r, angle1.degrees, angle2.degrees)
    end
    
    def to_su_curve_edge(group, pt1, pt2, pt3)
      x1 = pt1.x.mm
      x2 = pt2.x.mm
      x3 = pt3.x.mm

      y1 = pt1.y.mm
      y2 = pt2.y.mm
      y3 = pt3.y.mm

      z1 = pt1.z.mm
      z2 = pt2.z.mm
      z3 = pt3.z.mm

      x1x1 = x1 * x1
      y1y1 = y1 * y1
      x2x2 = x2 * x2
      y2y2 = y2 * y2
      x3x3 = x3 * x3
      y3y3 = y3 * y3

      x2y3 = x2 * y3
      x3y2 = x3 * y2

      x2_x3 = x2 - x3
      y2_y3 = y2 - y3

      x1x1py1y1 = x1x1 + y1y1
      x2x2py2y2 = x2x2 + y2y2
      x3x3py3y3 = x3x3 + y3y3

      a = x1 * y2_y3 - y1 * x2_x3 + x2y3 - x3y2
      b = x1x1py1y1 * (-y2_y3) + x2x2py2y2 * (y1 - y3) + x3x3py3y3 * (y2 -y1)
      c = x1x1py1y1 * x2_x3 + x2x2py2y2 * (x3 - x1) + x3x3py3y3 * (x1 - x2)
      d = x1x1py1y1 * (x3y2 - x2y3) + x2x2py2y2 * (x1 * y3 - x3 * y1) + x3x3py3y3 * (x2 * y1 - x1 * y2)

      x = -b / (2 * a)
      y = -c / (2 * a)
      z = z1
      r = Math.sqrt((b * b + c * c - 4 * a * d) / (4 * a * a))

      center_point = Geom::Point3d.new(x, y, z)
      # Create a circle perpendicular to the provided vector.
      normal = Z_AXIS
      xaxis = X_AXIS
      min_angle, max_angle = calculate_arc_angle(Geom::Point3d.new(x1, y1, z1) - center_point,Geom::Point3d.new(x2, y2, z2) - center_point,Geom::Point3d.new(x3, y3, z3) - center_point)
      edges = group.entities.add_arc(center_point, xaxis, Z_AXIS, r, min_angle, max_angle)
    end

    def to_su_line_edge(group, pt1, pt2)
      pt1 = Geom::Point3d.new(pt1.x.mm, pt1.y.mm, pt1.z.mm)
      pt2 = Geom::Point3d.new(pt2.x.mm, pt2.y.mm, pt2.z.mm)
      edges = group.entities.add_edges(pt1, pt2)
      edges.first
    end

    # 这里有一个深坑，SU的add_arc这个API不是按照顺时针或逆时针画弧的，也不看start_angle和end_angle的顺序关系
    # 也就是说，start_angle和end_angle这个参数的顺序并没有意义
    # 目前测试下来的结果是：
    # 对比start_angle和end_angle，找到最小值angle，然后按照最小值逆时针画弧画到最大值angle
    def calculate_arc_angle(vector1, vector2, vector3)
      angle1 = angle_in_plane(vector1, X_AXIS)
      angle2 = angle_in_plane(vector2, X_AXIS)
      angle3 = angle_in_plane(vector3, X_AXIS)
      min_angle = [angle1,angle3].min
      max_angle = [angle1,angle3].max
      if angle2 > min_angle and angle2 < max_angle
        return min_angle, max_angle
      else
        return max_angle - Math::PI * 2,min_angle
      end
    end

    # Counter-clockwise angle from vector2 to vector1, as seen from normal.
    def angle_in_plane(vector1, vector2, normal = Z_AXIS)
      value = Math.atan2((vector2 * vector1) % normal, vector1 % vector2)
      if value < 0
        value = Math::PI * 2 + value
      end
      value
    end

    # def multiple_transformations(scale, rotation, vector)
    #   # https://forums.sketchup.com/t/tranformation-move-and-rotate/154112
    #   var z_axis = Geom::Vector3d.new(0, 0, 1)
    #   var scale_trans = Geom::Transformation.scaling(scale, scale, scale)
    #   var rotation_trans = Geom::Transformation.rotation(ORIGIN, z_axis, rotation)
    #   var translation_trans = Geom::Transformation.translation(vector)
    #   translation_trans * rotation_trans * scale_trans
    # end

    def double_transformations(origin, direction)
      translation_trans = Geom::Transformation.new(origin, direction)
    end

    def multiple_transformations(scale, direction, origin)
      # https://forums.sketchup.com/t/tranformation-move-and-rotate/154112
      x_axis = Geom::Vector3d.new(1, 0, 0)
      scale_trans = Geom::Transformation.scaling(scale, scale, scale)
      rotation_trans = find_rotation_transformation(direction, x_axis)
      translation_trans = Geom::Transformation.translation(origin)
      translation_trans * rotation_trans * scale_trans
    end

    def find_rotation_transformation(vector1, vector2)
      # https://forums.sketchup.com/t/rotation-transformation-via-two-vectors/125678
      norm = (vector1 * vector2).normalize
      rot_angle = Math.atan2((vector1 * vector2) % norm, vector1 % vector2)
      Geom::Transformation.rotation(ORIGIN, norm, rot_angle)
    end

    def planar_angle(vector1, vector2)
      # https://forums.sketchup.com/t/rotation-transformation-via-two-vectors/125678
      normal = (vector1 * vector2).normalize
      Math.atan2((vector2 * vector1) % normal, vector1 % vector2)
    end

  end
end # module ThBM
