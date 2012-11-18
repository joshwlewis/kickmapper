class Map < ActiveRecord::Base
  attr_accessible :project_url
  
  has_and_belongs_to_many :locations

  after_save :read_locations, if: :read_locations?
  before_save :set_attributes

  def project
    @project ||= Project.new(url: project_url)
  end

  def latitudes
    locations.map(&:latitude)
  end

  def longitudes
    locations.map(&:longitude)
  end

  def center_longitude
    longitudes.sum / longitudes.size.to_f
  end

  def center_latitude
    latitudes.sum / latitudes.size.to_f
  end

  def backers
    Backer.by_project_url(project_url)
  end

  def read_locations?
    project_url_changed? || locations.blank?
  end

  def read_locations
    self.locations = backers.map(&:location).select{|l| l.latitude && l.longitude}
  end

  private

  def set_attributes
    [:name, :description, :image_url].each do |a|
      send :"#{a}=", project.send(a)
    end
  end

end
