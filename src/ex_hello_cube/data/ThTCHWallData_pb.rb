# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThTCHWallData.proto

require 'google/protobuf'

require 'ThTCHDoorData_pb'
require 'ThTCHWindowData_pb'
require 'ThTCHOpeningData_pb'
require 'ThTCHBuiltElementData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThTCHWallData.proto", :syntax => :proto3) do
    add_message "ThTCHWallData" do
      optional :build_element, :message, 1, "ThTCHBuiltElementData"
      repeated :doors, :message, 2, "ThTCHDoorData"
      repeated :windows, :message, 3, "ThTCHWindowData"
      repeated :openings, :message, 4, "ThTCHOpeningData"
    end
  end
end

ThTCHWallData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThTCHWallData").msgclass
