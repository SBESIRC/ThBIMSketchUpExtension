require 'sketchup.rb'
Sketchup.require 'tch_su_geom_utils'

module ThBM
  module ThTCH2SURAILINGFACTORY
    module_function
    def to_su_railing(entities, railing)
      begin
        railing_build_element = railing.build_element
        railing_group = entities.add_group
        railing_face = create_railing_face(railing_group, railing_build_element)
        railing_face.reverse! if railing_face.normal.z < 0 ; # flip face to up if facing down
        railing_face.pushpull(railing_build_element.height.mm)
        railing_group.definition.add_classification("IFC 2x3", "IfcRailing")
        railing_group.material = GlobalConfiguration.material_railing
        railing_group.name = "栏杆"
        railing_group.description = railing_build_element.root.globalId
        railing_group.locked = true
      rescue => e
        e.message
      end
    end

    def create_railing_face(group, build_element)
      face = ThTCH2SUGeomUtil.to_su_face(group, build_element.outline.shell)
    end
  end # module HelloCube
end # module ThBM

