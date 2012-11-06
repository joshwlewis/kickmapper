class Location < ActiveRecord::Base
  acts_as_gmappable process_geocoding: :geocode?, address: :address

  validates :address, presence: true

  def geocode?
    (address.present? && (latitude.blank? || longitude.blank?)) || address_changed?
  end

end
