class Location < ActiveRecord::Base

  geocoded_by :address

  has_and_belongs_to_many :maps
  
  validates :address, presence: true, uniqueness: true

  after_validation :geocode, if: :geocode?

  def geocode?
    (latitude.blank? || longitude.blank?) || address_changed?
  end

end
