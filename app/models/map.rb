class Map < ActiveRecord::Base
  serialize :location_data
  attr_accessible :location_data, :project_url

  def retrieve_location_data
    locations = Backer.by_project_url(project_url).map(&:location).select(&:present?)
    location_data = locations.each_with_object(Hash.new(0)) { |o, h| h[o] += 1 }
  end
end
