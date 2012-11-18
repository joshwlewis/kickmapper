class AddAddressIndexToLocations < ActiveRecord::Migration
  def change
    add_index :locations, :address
  end
end
