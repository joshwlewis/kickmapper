class Map < ActiveRecord::Base
  serialize :locations_cache
  attr_accessible :locations_cache, :project_url

  def retrieve_location_data
    self.location_data = locations_with_count
  end

  def backers
    Backer.by_project_url(project_url)
  end

  def locations
    self.locations_cache ||= backers.map(&:location).select(&:present?) 
  end

end
