require 'sketchup.rb'
require_relative 'tch_su_geom_utils.rb'

module Examples
  module ThTCH2SUSLABFACTORY
    module_function

    def to_su_slab(entities, slab, material)
      begin
      slab_build_element = slab.build_element
      slab_group = entities.add_group
      slab_face = create_slab_face(slab_group, slab_build_element)
      slab_face.reverse! if slab_face.normal.z > 0 ; # flip face to up if facing down
      slab_face.pushpull(slab_build_element.height.mm)

      descendings = slab.descendings
      descendings.each{ |descending|
          if descending.is_descending
              # 降板
              descending_buffer_group = entities.add_group
              descending_buffer_face = create_descending_buffer_face(descending_buffer_group, descending)
              descending_buffer_face.reverse! if descending_buffer_face.normal.z > 0 ; # flip face to up if facing down
              descending_buffer_face.pushpull((descending.descending_height + descending.descending_thickness).mm)
              union_group = slab_group.union(descending_buffer_group)
              if !union_group.nil?
                slab_group = union_group
              end
              descending_group = entities.add_group
              descending_face = create_descending_face(descending_group, descending)
              descending_face.reverse! if descending_face.normal.z > 0 ; # flip face to up if facing down
              descending_face.pushpull((descending.descending_height + 2).mm)
              subtract_group = descending_group.subtract(slab_group)
              if !subtract_group.nil?
                # entities.erase_entities slab_group
                slab_group = subtract_group
              end
          else
              # 洞
              slab_hole_group = entities.add_group
              slab_hole_face = create_slab_hole_face(slab_hole_group, descending)
              slab_hole_face.reverse! if slab_hole_face.normal.z > 0 ; # flip face to up if facing down
              slab_hole_face.pushpull((slab_build_element.height + 2).mm)
              slab_group = slab_hole_group.subtract(slab_group)
          end
      }
      slab_group.definition.add_classification("IFC 2x3", "IfcSlab")
      slab_group.material = material
      slab_group.name = "板"
      slab_group.description = slab_build_element.root.globalId
      slab_group.locked = true
      rescue => exception
        msg = exception.message
      end
    end

    def create_slab_face(group, build_element)
      pts = []
      build_element.outline.shell.points.each{ |pt|
        pts.push ThTCH2SUGeomUtil.to_su_point3d(pt)
      }
      face = group.entities.add_face(pts)
    end

    def create_slab_hole_face(group, descending)
        pts = []
        tr = Geom::Transformation.new(Geom::Point3d.new(0, 0, 1.mm))
        descending.outline.shell.points.each{ |pt|
          pts.push tr * ThTCH2SUGeomUtil.to_su_point3d(pt)
        }
        face = group.entities.add_face(pts)
    end

    def create_descending_face(group, descending)
        pts = []
        tr = Geom::Transformation.new(Geom::Point3d.new(0, 0, 1.mm))
        descending.outline.shell.points.each{ |pt|
          pts.push tr * ThTCH2SUGeomUtil.to_su_point3d(pt)
        }
        face = group.entities.add_face(pts)
    end

    def create_descending_buffer_face(group, descending)
        pts = []
        descending.outline_buffer.shell.points.each{ |pt|
          pts.push ThTCH2SUGeomUtil.to_su_point3d(pt)
        }
        face = group.entities.add_face(pts)
    end

  end # module HelloCube
end # module Examples

