# frozen_string_literal: true

class ExtractDetailsOnIpAddressJob < ApplicationJob
  queue_as :default

  def perform(ip_address)
    return if IpAddressDetail.where(ip: ip_address).exists?

    #NOTE: do not request this API too frequently in development or test environment because it is not stubbed and shared with production account.
    #NOTE: as of Jul 2019 IPDATA_CO_API_KEY uses Nick's personal free ipdata.co api key. Which free plan is quite permissive and we never had any quota limit warnings yet.
    # feel free to switch to corporate(LeaderBits) account/api key if you want to or if we hit the free quota limit and you notice some warnings. It is not urgent though - Nick will not revoke or invalidate this api key.
    uri = URI.parse("https://api.ipdata.co/#{ip_address}?api-key=#{ENV.fetch('IPDATA_CO_API_KEY')}")
    response = Net::HTTP.get_response(uri)

    unless response.code.to_i == 200
      Rollbar.info("Invalid response fromo ipdata.com", response_code: response.code, body: response.body, ip_address: ip_address)
    end

    raw_params = JSON.parse(response.body)

    IpAddressDetail.create! ip: ip_address,
                            country_name: raw_params.fetch('country_name'),
                            city: raw_params.fetch('city'),
                            region: raw_params.fetch('region'),
                            latitude: raw_params.fetch('latitude'),
                            longitude: raw_params.fetch('longitude'),
                            raw_params: raw_params
  end
end
