# frozen_string_literal: true

# require 'rails_helper'
# require 'ostruct'
#
# TEST_INTERCOM_EMAIL = 'integration-test@leaderbit.io'
#
# RSpec.describe IntercomContactSyncJob, type: :job do
#   def client
#     token = ENV.fetch('INTERCOM_ACCESS_TOKEN', nil)
#     client = Intercom::Client.new(token: token)
#   end
#
#   context 'given new intercom user' do
#     before do
#       begin
#         user = client.users.find(email: TEST_INTERCOM_EMAIL)
#         client.users.delete(user)
#       rescue Intercom::ResourceNotFound
#       end
#     end
#
#     let(:display_name) { 'FirstName LastName' }
#
#     example do
#       intercom_custom_data = {
#         admin_page: 'https:/some.url',
#         company_account_type: 'invididual',
#         completed_leaderbits_count: 0,
#         last_challenge_completed: 'last challenge',
#         momentum: "99%",
#         points: 123,
#         schedule_page: 'https://some.other.url',
#         schedule_type: 'global',
#         time_zone: 'EST',
#         upcoming_challenge: 'Challenge name',
#         uuid: 'abcd123uuid'
#       }
#       user = OpenStruct.new(email: TEST_INTERCOM_EMAIL,
#                             full_name: name,
#                             intercom_custom_data: intercom_custom_data,
#                             organization_id: 123,
#                             organization: OpenStruct.new(name: 'Integration Test Org Name'))
#
#       described_class.perform_now user
#
#       user = client.users.find(email: TEST_INTERCOM_EMAIL)
#       # => #<Intercom::User:0x000055a0324b7d00
#       #   @anonymous=false,
#       #     @app_id="jwaropjz",
#       #     @avatar=
#       #       #<Intercom::Avatar:0x000055a0324b6e00
#       #       @changed_fields=#<Set: {}>,
#       #         @image_url=nil,
#       #     @type="avatar">,
#       #     @changed_fields=#<Set: {}>,
#       #       @companies=
#       #         [#<Intercom::Company:0x000055a0324b6360
#       #           @changed_fields=#<Set: {}>,
#       #             @company_id="123",
#       #           @custom_attributes={},
#       #           @id="5b8d8ad309ef37ad1747a7bc",
#       #           @name="Integration Test Org Name",
#       #           @type="company">],
#       #     @created_at=1536002086,
#       #     @custom_attributes=
#       #       {"points"=>123,
#       #        "admin_page"=>"https:/some.url",
#       #        "upcoming_challenge"=>"some text",
#       #        "last_challenge_completed"=>"some other text"},
#       #     @email="integration-test@leaderbit.io",
#       #     @has_hard_bounced=false,
#       #     @id="5b8d88263dd187f982b49cd9",
#       #     @last_request_at=nil,
#       #     @last_seen_ip=nil,
#       #     @location_data={},
#       #     @marked_email_as_spam=false,
#       #     @name=nil,
#       #     @phone=nil,
#       #     @pseudonym=nil,
#       #     @referrer=nil,
#       #     @remote_created_at=nil,
#       #     @segments=[],
#       #     @session_count=0,
#       #     @signed_up_at=nil,
#       #     @social_profiles=[],
#       #     @tags=[],
#       #     @type="user",
#       #     @unsubscribed_from_emails=false,
#       #     @updated_at=1536002771,
#       #     @user_agent_data=nil,
#       #     @user_id=nil,
#       #     @utm_campaign=nil,
#       #     @utm_content=nil,
#       #     @utm_medium=nil,
#       #     @utm_source=nil,
#       #     @utm_term=nil>
#
#       debugger
#       expect(user.email).to eq(TEST_INTERCOM_EMAIL)
#       expect(user.name).to eq(display_name)
#       expect(user.custom_attributes.symbolize_keys).to eq(intercom_custom_data)
#       expect(user.created_at).to eq(Time.now)
#
#       expect(user.companies.first.company_id).to eq("123")
#       expect(user.companies.first.name).to eq("Integration Test Org Name")
#       expect(user.companies.first.custom_attributes).to eq({})
#    end
#   end
#
#   context 'given existing intercom user' do
#     before do
#       begin
#         user = client.users.find(email: TEST_INTERCOM_EMAIL)
#         client.users.delete(user)
#       rescue Intercom::ResourceNotFound
#         #ok, just create new user
#       end
#       client.users.create(email: TEST_INTERCOM_EMAIL)
#     end
#
#     let(:name) { 'FirstName LastName' }
#
#     example do
#       require 'ostruct'
#       intercom_custom_data = {
#         points: 123,
#         admin_page: 'https:/some.url',
#         upcoming_challenge: 'some text',
#         last_challenge_completed: 'some other text'
#       }
#       user = OpenStruct.new(email: TEST_INTERCOM_EMAIL,
#                             name: name,
#                             intercom_custom_data: intercom_custom_data,
#                             organization_id: 123,
#                             organization: OpenStruct.new(name: 'Integration Test Org Name'))
#
#       described_class.perform_now user
#
#       user = client.users.find(email: TEST_INTERCOM_EMAIL)
#
#       expect(user.email).to eq(TEST_INTERCOM_EMAIL)
#       expect(user.name).to eq(name)
#       expect(user.custom_attributes.symbolize_keys).to eq(intercom_custom_data)
#       expect(user.created_at).to eq(Time.now)
#
#       expect(user.companies.first.company_id).to eq("123")
#       expect(user.companies.first.name).to eq("Integration Test Org Name")
#       expect(user.companies.first.custom_attributes).to eq({})
#     end
#   end
# end
