# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license

require 'sketchup.rb'
require 'extensions.rb'

module ThBM # TODO: Change module name to fit the project.
  module HelloCube

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('天华结构三维平台SU客户端', 'ex_thbim/main')
      ex.description = 'SketchUp extension for TIANHUA Structure 3D Platform.'
      ex.version     = '1.0.0'
      ex.copyright   = 'Tianhua Architectural Design Co., Ltd'
      ex.creator     = 'TIANHUA AI Research Center'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end # module HelloCube
end # module ThBM
