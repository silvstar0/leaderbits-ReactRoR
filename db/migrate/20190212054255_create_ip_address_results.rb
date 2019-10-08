# frozen_string_literal: true

class CreateIpAddressResults < ActiveRecord::Migration[5.2]
  def change
    create_table :ip_address_details do |t|
      t.inet :ip, null: false, uniq: true, index: true
      t.string :country_name
      t.string :city
      t.string :region

      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.json :raw_params
    end
  end
end
