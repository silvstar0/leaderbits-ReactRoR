# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_address_details
#
#  id           :bigint(8)        not null, primary key
#  ip           :inet             not null
#  country_name :string
#  city         :string
#  region       :string
#  latitude     :decimal(10, 6)
#  longitude    :decimal(10, 6)
#  raw_params   :json
#

class IpAddressDetail < ApplicationRecord
end
