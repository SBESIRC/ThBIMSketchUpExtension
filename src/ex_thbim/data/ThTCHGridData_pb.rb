# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThTCHGridData.proto

require 'google/protobuf'

require 'ThTCHGridAxisData_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThTCHGridData.proto", :syntax => :proto3) do
    add_message "ThTCHGridData" do
      repeated :u_axes, :message, 1, "ThTCHGridAxisData"
      repeated :v_axes, :message, 2, "ThTCHGridAxisData"
    end
  end
end

ThTCHGridData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("ThTCHGridData").msgclass
