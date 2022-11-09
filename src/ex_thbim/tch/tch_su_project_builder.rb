require 'sketchup.rb'
require_relative 'tch_su_storey_factory.rb'

module Examples
  module HelloCube
    class ThTCH2SUProjectBuilder
        @@model_cache = ThTCHProjectData.new;
        @@material_dic = Hash.new
        def self.Building(data)
          if data.is_a?(ThTCHProjectData)
            self.check_material
            if data == @@model_cache
              # do not
            else
              # 数据需刷新
              if @@model_cache.sites.first.nil? or @@model_cache.sites.first.root.globalId != data.sites.first.root.globalId
                # 缓存为空，说明是新数据,全刷新
                self.full_refresh(data)
              else
                # 缓存与本次数据是同源，增量更新
                self.incremental_update(data)
              end
              @@model_cache = data
            end
          end
        end

        def self.check_material
          if @@material_dic.length < 5
            materials = Sketchup.active_model.materials
            @@material_dic["door"] = materials.load(File.expand_path('../../Material/door.skm', __FILE__))
            @@material_dic["slab"] = materials.load(File.expand_path('../../Material/slab.skm', __FILE__))
            @@material_dic["wall"] = materials.load(File.expand_path('../../Material/wall.skm', __FILE__))
            @@material_dic["window"] = materials.load(File.expand_path('../../Material/window.skm', __FILE__))
            @@material_dic["railing"] = materials.load(File.expand_path('../../Material/railing.skm', __FILE__))
          end
        end

        # 全刷新
        def self.full_refresh(data)
          project_site = data.sites.first
          project_site_buildings = project_site.buildings
          # 暂时先假定只有一个building，等后续多建筑后再去扩展
          building = project_site_buildings.first
          building.storeys.each{ |storey|
            # 后期在这里做逻辑
            # 创建geometry
            ThTCH2SUStoreyFactory.full_refresh_floor(Sketchup.active_model, data.root.globalId, storey, @@material_dic)
          }
        end

        # 增量更新
        def self.incremental_update(data)
          project_site = data.sites.first
          project_site_buildings = project_site.buildings
          # 暂时先假定只有一个building，等后续多建筑后再去扩展
          building = project_site_buildings.first
          # 拿到缓存数据
          all_cache_storeys = @@model_cache.site.buildings.first.storeys
          building.storeys.each{ |storey|
            cache_storeys = all_cache_storeys.select{ |o| o.build_element.root.globalId == storey.build_element.root.globalId }
            if !cache_storeys.nil? and cache_storeys.length == 1
              cache_storey = cache_storeys.first
              if cache_storey != storey
                ThTCH2SUStoreyFactory.incremental_update_floor(Sketchup.active_model, data.root.globalId, storey, cache_storey, @@material_dic)
              end
            else
              ThTCH2SUStoreyFactory.full_refresh_floor(Sketchup.active_model, data.root.globalId, storey, @@material_dic)
            end
            
          }
        end
    end
  end # module HelloCube
end # module Examples
