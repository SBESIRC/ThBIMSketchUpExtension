Sketchup.require 'sketchup'
Sketchup.require 'tch_su_storey_factory'

module ThBM
  class ThTCHProjectBuilder
    @@model_cache = ThTCHProjectData.new
    def self.building_project(data)
      if data.is_a?(ThTCHProjectData)
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

    # 全刷新
    def self.full_refresh(data)
      project_site = data.sites.first
      project_site_buildings = project_site.buildings
      # 暂时先假定只有一个building，等后续多建筑后再去扩展
      building = project_site_buildings.first
      building.storeys.each{ |storey|
        # 后期在这里做逻辑
        # 创建geometry
        ThTCHStoreyFactory.full_refresh_floor(Sketchup.active_model, data.root.globalId, storey)
      }
    end

    # 增量更新
    def self.incremental_update(data)
      project_site = data.sites.first
      project_site_buildings = project_site.buildings
      # 暂时先假定只有一个building，等后续多建筑后再去扩展
      building = project_site_buildings.first
      # 拿到缓存数据
      all_cache_storeys = @@model_cache.sites.first.buildings.first.storeys
      building.storeys.each{ |storey|
        cache_storeys = all_cache_storeys.select{ |o| o.build_element.root.globalId == storey.build_element.root.globalId }
        if !cache_storeys.nil? and cache_storeys.length == 1
          cache_storey = cache_storeys.first
          if cache_storey != storey
            ThTCHStoreyFactory.incremental_update_floor(Sketchup.active_model, data.root.globalId, storey, cache_storey)
          end
        else
          ThTCHStoreyFactory.full_refresh_floor(Sketchup.active_model, data.root.globalId, storey)
        end
        
      }
    end
  end

  class ThSUProjectBuilder
    def self.building_project(data)
      if data.is_a?(ThSUProjectData)
        self.full_refresh(data)
      end
    end

    # 全刷新
    def self.full_refresh(data)
      definitions = data.definitions
      data.building.storeys.each{ |storey|
        ThSUStoreyFactory.full_refresh_floor(definitions, storey)
      }
    end
  end
end # module ThBM
