class Map < ActiveRecord::Base
  serialize :location_data
  attr_accessible :location_data, :project_url

  def project
    @project ||= Project.new
  end
end
