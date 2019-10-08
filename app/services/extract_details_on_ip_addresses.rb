# frozen_string_literal: true

class ExtractDetailsOnIpAddresses
  def self.call
    current_ips = User.pluck(:current_sign_in_ip, :last_sign_in_ip).flatten.compact
    logged_ips = IpAddressDetail.pluck(:ip)

    # free daily limit is 1500 as of Feb 2019
    (current_ips - logged_ips).take(1000).each do |ip|
      ExtractDetailsOnIpAddressJob.perform_later ip.to_s
    end
  end
end
