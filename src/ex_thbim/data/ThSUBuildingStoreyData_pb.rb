# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThSUBuildingStoreyData.proto

require 'google/protobuf'

require 'ThTCHRootData_pb'
require 'ThSUBuildingElementData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThSUBuildingStoreyData.proto", :syntax => :proto3) do
    add_message "ThSUBuildingStoreyData" do
      optional :root, :message, 1, "ThTCHRootData"
      repeated :buildings, :message, 2, "ThSUBuildingElementData"
      optional :number, :int32, 3
      optional :height, :double, 4
      optional :elevation, :double, 5
      optional :stdFlr_no, :int32, 6
    end
  end
end

ThSUBuildingStoreyData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThSUBuildingStoreyData").msgclass