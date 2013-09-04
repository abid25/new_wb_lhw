class AddLocationToPhoneEntry < ActiveRecord::Migration
  def self.up
  	add_column :phone_entries, :address, :string
  end
end
