module ThBM
    class GlobalConfiguration
        @@material_door = Sketchup.active_model.materials.load(File.expand_path('../../Material/door.skm', __FILE__))
        @@material_slab = Sketchup.active_model.materials.load(File.expand_path('../../Material/slab.skm', __FILE__))
        @@material_wall = Sketchup.active_model.materials.load(File.expand_path('../../Material/wall.skm', __FILE__))
        @@material_window = Sketchup.active_model.materials.load(File.expand_path('../../Material/window.skm', __FILE__))
        @@material_railing = Sketchup.active_model.materials.load(File.expand_path('../../Material/railing.skm', __FILE__))
        @@material_beam = Sketchup.active_model.materials.load(File.expand_path('../../Material/beam.skm', __FILE__))
        @@material_column = Sketchup.active_model.materials.load(File.expand_path('../../Material/column.skm', __FILE__))

        # Get
        def self.material_door
            @@material_door
        end

        def self.material_slab
            @@material_slab
        end

        def self.material_wall
            @@material_wall
        end

        def self.material_railing
            @@material_railing
        end

        def self.material_beam
            @@material_beam
        end

        def self.material_column
            @@material_column
        end

        def self.material_window
            @@material_window
        end
    end
end # module ThBM