# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/protobuf/duration.proto

Sketchup.require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("google/protobuf/duration.proto", :syntax => :proto3) do
    add_message "google.protobuf.Duration" do
      optional :seconds, :int64, 1
      optional :nanos, :int32, 2
    end
  end
end

module Google
  module Protobuf
    Duration = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.protobuf.Duration").msgclass
  end
end
