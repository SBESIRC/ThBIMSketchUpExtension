# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThSULoopData.proto

require 'google/protobuf'

require 'ThTCHGeometry_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThSULoopData.proto", :syntax => :proto3) do
    add_message "ThSULoopData" do
      repeated :points, :message, 1, "ThTCHPoint3d"
    end
  end
end

ThSULoopData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThSULoopData").msgclass