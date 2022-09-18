# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license

require 'sketchup.rb'
require 'extensions.rb'

module Examples # TODO: Change module name to fit the project.
  module HelloCube

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('THAI Bim Extension', 'ex_thbim/main')
      ex.description = 'THAI Bim Extension for SketchUp.'
      ex.version     = '1.0.0'
      ex.copyright   = 'THAI © 2022-~'
      ex.creator     = 'SketchUp'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end # module HelloCube
end # module Examples
