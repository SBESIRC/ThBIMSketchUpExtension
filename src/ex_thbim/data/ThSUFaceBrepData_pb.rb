# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThSUFaceBrepData.proto

require 'google/protobuf'

require 'ThSULoopData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThSUFaceBrepData.proto", :syntax => :proto3) do
    add_message "ThSUFaceBrepData" do
      optional :outer_loop, :message, 1, "ThSULoopData"
      repeated :inner_loops, :message, 2, "ThSULoopData"
    end
  end
end

ThSUFaceBrepData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThSUFaceBrepData").msgclass
