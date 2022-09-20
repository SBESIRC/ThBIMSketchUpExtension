# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThTCHWallData.proto

require 'google/protobuf'

require 'ThTCHGeometry_pb'
require 'ThTCHDoorData_pb'
require 'ThTCHWindowData_pb'
require 'ThTCHOpeningData_pb'
require 'ThTCHBuiltElementData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThTCHWallData.proto", :syntax => :proto3) do
    add_message "ThTCHWallData" do
      optional :build_element, :message, 1, "ThTCHBuiltElementData"
      optional :left_width, :double, 2
      optional :right_width, :double, 3
      optional :start_point, :message, 4, "ThTCHPoint3d"
      optional :end_point, :message, 5, "ThTCHPoint3d"
      repeated :doors, :message, 6, "ThTCHDoorData"
      repeated :windows, :message, 7, "ThTCHWindowData"
      repeated :openings, :message, 8, "ThTCHOpeningData"
    end
  end
end

ThTCHWallData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThTCHWallData").msgclass