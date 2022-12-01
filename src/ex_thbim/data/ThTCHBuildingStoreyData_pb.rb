# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThTCHBuildingStoreyData.proto

Sketchup.require 'google/protobuf'

Sketchup.require 'ThTCHBuiltElementData_pb'
Sketchup.require 'ThTCHWallData_pb'
Sketchup.require 'ThTCHDoorData_pb'
Sketchup.require 'ThTCHGeometry_pb'
Sketchup.require 'ThTCHWindowData_pb'
Sketchup.require 'ThTCHSlabData_pb'
Sketchup.require 'ThTCHRailingData_pb'
Sketchup.require 'ThTCHRoomData_pb'
Sketchup.require 'ThGridLineSyetemData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThTCHBuildingStoreyData.proto", :syntax => :proto3) do
    add_message "ThTCHBuildingStoreyData" do
      optional :build_element, :message, 1, "ThTCHBuiltElementData"
      optional :number, :string, 2
      optional :height, :double, 3
      optional :elevation, :double, 4
      optional :usage, :string, 5
      optional :origin, :message, 6, "ThTCHPoint3d"
      optional :memory_storey_id, :string, 7
      optional :memory_matrix3d, :message, 8, "ThTCHMatrix3d"
      repeated :walls, :message, 9, "ThTCHWallData"
      repeated :doors, :message, 10, "ThTCHDoorData"
      repeated :windows, :message, 11, "ThTCHWindowData"
      repeated :slabs, :message, 12, "ThTCHSlabData"
      repeated :railings, :message, 13, "ThTCHRailingData"
      repeated :rooms, :message, 14, "ThTCHRoomData"
      optional :grid_line_system, :message, 15, "ThGridLineSyetemData"
    end
  end
end

ThTCHBuildingStoreyData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThTCHBuildingStoreyData").msgclass
