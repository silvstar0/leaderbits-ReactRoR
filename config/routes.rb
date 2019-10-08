# frozen_string_literal: true

# == Route Map
#
#                                                   Prefix Verb     URI Pattern                                                                              Controller#Action
#                                         new_user_session GET      /users/sign_in(.:format)                                                                 devise_overridden/sessions#new
#                                             user_session POST     /users/sign_in(.:format)                                                                 devise_overridden/sessions#create
#                                     destroy_user_session GET      /users/sign_out(.:format)                                                                devise_overridden/sessions#destroy
#                                        new_user_password GET      /users/password/new(.:format)                                                            devise/passwords#new
#                                       edit_user_password GET      /users/password/edit(.:format)                                                           devise/passwords#edit
#                                            user_password PATCH    /users/password(.:format)                                                                devise/passwords#update
#                                                          PUT      /users/password(.:format)                                                                devise/passwords#update
#                                                          POST     /users/password(.:format)                                                                devise/passwords#create
#                                                dashboard GET      /dashboard(.:format)                                                                     home#dashboard
#                                               onboarding POST     /onboarding(.:format)                                                                    onboarding#update
#                                            postmark_show GET      /postmark/show(.:format)                                                                 postmark#show
#                                        expired_auth_link GET      /expired-auth-link(.:format)                                                             expired_auth_links#show
#                              expired_auth_link_send_link GET|POST /expired-auth-link/send_link(.:format)                                                   expired_auth_links#send_link
#                                            welcome_video GET      /welcome(.:format)                                                                       home#welcome_video
#                                                    step2 GET      /step2(.:format)                                                                         multi_step_leader_sign_up#leader_strength_finder
#                                                    step3 GET      /step3(.:format)                                                                         multi_step_leader_sign_up#team_survey_360
#                                                    step4 GET      /step4(.:format)                                                                         multi_step_leader_sign_up#mentorship
#                                      user_reset_password POST     /users/reset-password(.:format)                                                          users#reset_password
#                       user_anonymous_survey_participants PUT      /users/:user_id/anonymous_survey_participants(.:format)                                  anonymous_survey_participants#update
#                                                edit_user GET      /users/:id/edit(.:format)                                                                users#edit
#                                                     user GET      /users/:id(.:format)                                                                     users#show
#                                                          PATCH    /users/:id(.:format)                                                                     users#update
#                                                          PUT      /users/:id(.:format)                                                                     users#update
#                                                    users POST     /users(.:format)                                                                         users#create
#                               progress_report_recipients POST     /progress_report_recipients(.:format)                                                    progress_report_recipients#create
#                                progress_report_recipient PATCH    /progress_report_recipients/:id(.:format)                                                progress_report_recipients#update
#                                                          PUT      /progress_report_recipients/:id(.:format)                                                progress_report_recipients#update
#                                                          DELETE   /progress_report_recipients/:id(.:format)                                                progress_report_recipients#destroy
#                            anonymous_survey_participants POST     /anonymous_survey_participants(.:format)                                                 anonymous_survey_participants#create
#                             anonymous_survey_participant PATCH    /anonymous_survey_participants/:id(.:format)                                             anonymous_survey_participants#update
#                                                          PUT      /anonymous_survey_participants/:id(.:format)                                             anonymous_survey_participants#update
#                                                          DELETE   /anonymous_survey_participants/:id(.:format)                                             anonymous_survey_participants#destroy
#                                             team_members POST     /team_members(.:format)                                                                  team_members#create
#                                              team_member PATCH    /team_members/:id(.:format)                                                              team_members#update
#                                                          PUT      /team_members/:id(.:format)                                                              team_members#update
#                                                          DELETE   /team_members/:id(.:format)                                                              team_members#destroy
#                         accept_organizational_mentorship GET      /organizational_mentorships/:id/accept(.:format)                                         organizational_mentorships#accept
#                               organizational_mentorships POST     /organizational_mentorships(.:format)                                                    organizational_mentorships#create
#                                organizational_mentorship PATCH    /organizational_mentorships/:id(.:format)                                                organizational_mentorships#update
#                                                          PUT      /organizational_mentorships/:id(.:format)                                                organizational_mentorships#update
#                                                          DELETE   /organizational_mentorships/:id(.:format)                                                organizational_mentorships#destroy
#                                                          GET      /user_mentees/:id/accept(.:format)                                                       redirect(301)
#                                                          GET      /mentorships/:id/accept(.:format)                                                        redirect(301)
#                                                          GET      /robots.txt(.:format)                                                                    home#robots
#                                 webhooks_postmark_bounce POST     /webhooks/postmark-bounce(.:format)                                                      webhooks#postmark_bounce
#                                  toggle_like_entry_reply GET|POST /entry_replies/:id/toggle_like(.:format)                                                 entry_replies#toggle_like
#                                            entry_replies POST     /entry_replies(.:format)                                                                 entry_replies#create
#                                              entry_reply PATCH    /entry_replies/:id(.:format)                                                             entry_replies#update
#                                                          PUT      /entry_replies/:id(.:format)                                                             entry_replies#update
#                                                          DELETE   /entry_replies/:id(.:format)                                                             entry_replies#destroy
#                                          profile_billing GET|POST /profile/billing(.:format)                                                               profile#billing
#                                 profile_setting_password PUT      /profile/setting_password(.:format)                                                      profile#setting_password
#                                              profile_api GET      /profile/api(.:format)                                                                   profile#api
#                                       profile_engagement GET|POST /profile/engagement(.:format)                                                            profile#engagement
#                                       profile_mentorship GET      /profile/mentorship(.:format)                                                            profile#mentorship
#                                  profile_team_survey_360 GET      /profile/team-survey-360(.:format)                                                       profile#team_survey_360
#                                   profile_accountability GET      /profile/accountability(.:format)                                                        profile#accountability
#                                        leaderbit_entries POST     /leaderbits/:leaderbit_id/entries(.:format)                                              entries#create
#                                     edit_leaderbit_entry GET      /leaderbits/:leaderbit_id/entries/:id/edit(.:format)                                     entries#edit
#                                          leaderbit_entry GET      /leaderbits/:leaderbit_id/entries/:id(.:format)                                          entries#show
#                                                          PATCH    /leaderbits/:leaderbit_id/entries/:id(.:format)                                          entries#update
#                                                          PUT      /leaderbits/:leaderbit_id/entries/:id(.:format)                                          entries#update
#                                                          DELETE   /leaderbits/:leaderbit_id/entries/:id(.:format)                                          entries#destroy
#                                     leaderbit_boomerangs POST     /leaderbits/:leaderbit_id/boomerangs(.:format)                                           boomerangs#create
#                                          start_leaderbit GET      /leaderbits/:id/start(.:format)                                                          leaderbits#start
#                                               leaderbits GET      /leaderbits(.:format)                                                                    leaderbits#index
#                                                leaderbit GET      /leaderbits/:id(.:format)                                                                leaderbits#show
#                                   challenges_begin_first GET|POST /challenges/begin-first(.:format)                                                        leaderbits#begin_first_challenge
#                                              sidekiq_web          /sidekiq                                                                                 Sidekiq::Web
#                                                   blazer          /blazer                                                                                  Blazer::Engine
#                           participate_anonymously_survey GET|POST /surveys/:id/participate_anonymously(.:format)                                           surveys#participate_anonymously
#                       anonymous_survey_completed_surveys GET      /surveys/anonymous_survey_completed(.:format)                                            surveys#anonymous_survey_completed
#                                           survey_answers POST     /surveys/:survey_id/answers(.:format)                                                    answers#create
#                                          admin_dashboard GET      /admin(.:format)                                                                         admin/home#root
#                                             admin_report GET      /admin/report(.:format)                                                                  admin/home#report
#                                         admin_user_notes PUT      /admin/user-notes(.:format)                                                              admin/user_notes#update
#                                             admin_audits GET      /admin/audits(.:format)                                                                  admin/audits#index
#                                         admin_leaderbits GET      /admin/leaderbits(.:format)                                                              admin/leaderbits#index
#                                                          POST     /admin/leaderbits(.:format)                                                              admin/leaderbits#create
#                                      new_admin_leaderbit GET      /admin/leaderbits/new(.:format)                                                          admin/leaderbits#new
#                                     edit_admin_leaderbit GET      /admin/leaderbits/:id/edit(.:format)                                                     admin/leaderbits#edit
#                                          admin_leaderbit GET      /admin/leaderbits/:id(.:format)                                                          admin/leaderbits#show
#                                                          PATCH    /admin/leaderbits/:id(.:format)                                                          admin/leaderbits#update
#                                                          PUT      /admin/leaderbits/:id(.:format)                                                          admin/leaderbits#update
#                                              admin_teams GET      /admin/teams(.:format)                                                                   admin/teams#index
#                                               admin_team GET      /admin/teams/:id(.:format)                                                               admin/teams#show
#                                               admin_tags GET      /admin/tags(.:format)                                                                    admin/tags#index
#                                           edit_admin_tag GET      /admin/tags/:id/edit(.:format)                                                           admin/tags#edit
#                                                admin_tag GET      /admin/tags/:id(.:format)                                                                admin/tags#show
#                                                          PATCH    /admin/tags/:id(.:format)                                                                admin/tags#update
#                                                          PUT      /admin/tags/:id(.:format)                                                                admin/tags#update
#                              sort_admin_survey_questions POST     /admin/surveys/:survey_id/questions/sort(.:format)                                       admin/questions#sort
#                                   admin_survey_questions POST     /admin/surveys/:survey_id/questions(.:format)                                            admin/questions#create
#                                new_admin_survey_question GET      /admin/surveys/:survey_id/questions/new(.:format)                                        admin/questions#new
#                               edit_admin_survey_question GET      /admin/surveys/:survey_id/questions/:id/edit(.:format)                                   admin/questions#edit
#                                    admin_survey_question GET      /admin/surveys/:survey_id/questions/:id(.:format)                                        admin/questions#show
#                                                          PATCH    /admin/surveys/:survey_id/questions/:id(.:format)                                        admin/questions#update
#                                                          PUT      /admin/surveys/:survey_id/questions/:id(.:format)                                        admin/questions#update
#                                                          DELETE   /admin/surveys/:survey_id/questions/:id(.:format)                                        admin/questions#destroy
#                                            admin_surveys GET      /admin/surveys(.:format)                                                                 admin/surveys#index
#                                        edit_admin_survey GET      /admin/surveys/:id/edit(.:format)                                                        admin/surveys#edit
#                                             admin_survey GET      /admin/surveys/:id(.:format)                                                             admin/surveys#show
#                                                          PATCH    /admin/surveys/:id(.:format)                                                             admin/surveys#update
#                                                          PUT      /admin/surveys/:id(.:format)                                                             admin/surveys#update
#                                      sort_admin_schedule POST     /admin/schedules/:id/sort(.:format)                                                      admin/schedules#sort
#                                     clone_admin_schedule POST     /admin/schedules/:id/clone(.:format)                                                     admin/schedules#clone
#                             add_leaderbit_admin_schedule POST     /admin/schedules/:id/add_leaderbit(.:format)                                             admin/schedules#add_leaderbit
#                          remove_leaderbit_admin_schedule POST     /admin/schedules/:id/remove_leaderbit(.:format)                                          admin/schedules#remove_leaderbit
#                                          admin_schedules GET      /admin/schedules(.:format)                                                               admin/schedules#index
#                                                          POST     /admin/schedules(.:format)                                                               admin/schedules#create
#                                       new_admin_schedule GET      /admin/schedules/new(.:format)                                                           admin/schedules#new
#                                      edit_admin_schedule GET      /admin/schedules/:id/edit(.:format)                                                      admin/schedules#edit
#                                           admin_schedule GET      /admin/schedules/:id(.:format)                                                           admin/schedules#show
#                                                          PATCH    /admin/schedules/:id(.:format)                                                           admin/schedules#update
#                                                          PUT      /admin/schedules/:id(.:format)                                                           admin/schedules#update
#                                                          DELETE   /admin/schedules/:id(.:format)                                                           admin/schedules#destroy
#         send_lifetime_progress_report_admin_organization POST     /admin/organizations/:id/send_lifetime_progress_report(.:format)                         admin/organizations#send_lifetime_progress_report
#                                      admin_organizations GET      /admin/organizations(.:format)                                                           admin/organizations#index
#                                                          POST     /admin/organizations(.:format)                                                           admin/organizations#create
#                                   new_admin_organization GET      /admin/organizations/new(.:format)                                                       admin/organizations#new
#                                  edit_admin_organization GET      /admin/organizations/:id/edit(.:format)                                                  admin/organizations#edit
#                                       admin_organization GET      /admin/organizations/:id(.:format)                                                       admin/organizations#show
#                                                          PATCH    /admin/organizations/:id(.:format)                                                       admin/organizations#update
#                                                          PUT      /admin/organizations/:id(.:format)                                                       admin/organizations#update
#                                                          DELETE   /admin/organizations/:id(.:format)                                                       admin/organizations#destroy
#                         admin_organizational_mentorships POST     /admin/organizational_mentorships(.:format)                                              admin/organizational_mentorships#create
#                          admin_organizational_mentorship DELETE   /admin/organizational_mentorships/:id(.:format)                                          admin/organizational_mentorships#destroy
# destroy_by_leaderbit_id_admin_user_preemptive_leaderbits DELETE   /admin/users/:user_id/preemptive_leaderbits/destroy_by_leaderbit_id(.:format)            admin/preemptive_leaderbits#destroy_by_leaderbit_id
#                     sort_admin_user_preemptive_leaderbit POST     /admin/users/:user_id/preemptive_leaderbits/:id/sort(.:format)                           admin/preemptive_leaderbits#sort
#                         admin_user_preemptive_leaderbits POST     /admin/users/:user_id/preemptive_leaderbits(.:format)                                    admin/preemptive_leaderbits#create
#                                toggle_discard_admin_user POST     /admin/users/:id/toggle_discard(.:format)                                                admin/users#toggle_discard
#                                password_reset_admin_user GET      /admin/users/:id/password_reset(.:format)                                                admin/users#password_reset
#        trigger_next_leaderbit_instant_sending_admin_user POST     /admin/users/:id/trigger_next_leaderbit_instant_sending(.:format)                        admin/users#trigger_next_leaderbit_instant_sending
#                 send_lifetime_progress_report_admin_user POST     /admin/users/:id/send_lifetime_progress_report(.:format)                                 admin/users#send_lifetime_progress_report
#                                              admin_users GET      /admin/users(.:format)                                                                   admin/users#index
#                                                          POST     /admin/users(.:format)                                                                   admin/users#create
#                                           new_admin_user GET      /admin/users/new(.:format)                                                               admin/users#new
#                                          edit_admin_user GET      /admin/users/:id/edit(.:format)                                                          admin/users#edit
#                                               admin_user GET      /admin/users/:id(.:format)                                                               admin/users#show
#                                                          PATCH    /admin/users/:id(.:format)                                                               admin/users#update
#                                                          PUT      /admin/users/:id(.:format)                                                               admin/users#update
#                                                          DELETE   /admin/users/:id(.:format)                                                               admin/users#destroy
#                                      admin_vacation_mode DELETE   /admin/vacation_modes/:id(.:format)                                                      admin/vacation_modes#destroy
#                                        achievement_modal GET      /achievement-modal(.:format)                                                             achievements#show
#                                    preemptive_leaderbits POST     /preemptive_leaderbits(.:format)                                                         preemptive_leaderbits#create
#                                           vacation_modes POST     /vacation_modes(.:format)                                                                vacation_modes#create
#                                            vacation_mode PATCH    /vacation_modes/:id(.:format)                                                            vacation_modes#update
#                                                          PUT      /vacation_modes/:id(.:format)                                                            vacation_modes#update
#                                                          DELETE   /vacation_modes/:id(.:format)                                                            vacation_modes#destroy
#                                                    teams POST     /teams(.:format)                                                                         teams#create
#                                                 new_team GET      /teams/new(.:format)                                                                     teams#new
#                                                edit_team GET      /teams/:id/edit(.:format)                                                                teams#edit
#                                                     team PATCH    /teams/:id(.:format)                                                                     teams#update
#                                                          PUT      /teams/:id(.:format)                                                                     teams#update
#                                                  company GET      /company(.:format)                                                                       companies#show
#                                 strength_levels_settings GET      /settings/strength_levels(.:format)                                                      settings#strength_levels
#                                                          PATCH    /settings/strength_levels(.:format)                                                      settings#strength_levels
#                                       analytics_settings GET      /settings/analytics(.:format)                                                            settings#analytics
#                                       community_settings GET      /settings/community(.:format)                                                            settings#community
#                                  investigation_166012032 GET      /investigation-166012032(.:format)                                                       investigations#show
#                             joels_responses_entry_groups GET      /leaderbit-entries/joels_responses(.:format)                                             entry_groups#joels_responses
#                                 mark_as_read_entry_group POST     /leaderbit-entries/:id/mark_as_read(.:format)                                            entry_groups#mark_as_read
#                                             entry_groups GET      /leaderbit-entries(.:format)                                                             entry_groups#index
#                                              entry_group GET      /leaderbit-entries/:id(.:format)                                                         entry_groups#show
#                                        toggle_like_entry POST     /entries/:id/toggle_like(.:format)                                                       entries#toggle_like
#                                                  entries POST     /entries(.:format)                                                                       entries#create
#                                               edit_entry GET      /entries/:id/edit(.:format)                                                              entries#edit
#                                                    entry GET      /entries/:id(.:format)                                                                   entries#show
#                                                          PATCH    /entries/:id(.:format)                                                                   entries#update
#                                                          PUT      /entries/:id(.:format)                                                                   entries#update
#                                                                   /cable                                                                                   #<ActionCable::Server::Base:0x0000558dc8d1fe38 @mutex=#<Monitor:0x0000558dc8d1fe10 @mon_mutex=#<Thread::Mutex:0x0000558dc8d1fdc0>, @mon_mutex_owner_object_id=47033723977480, @mon_owner=nil, @mon_count=0>, @pubsub=nil, @worker_pool=nil, @event_loop=nil, @remote_connections=nil>
#                                                     root GET      /                                                                                        home#root
#                                              switch_user GET      /switch_user(.:format)                                                                   switch_user#set_current_user
#                                switch_user_remember_user GET      /switch_user/remember_user(.:format)                                                     switch_user#remember_user
#                                                     page GET      /pages/*id                                                                               high_voltage/pages#show
#                                       rails_service_blob GET      /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#                                rails_blob_representation GET      /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#                                       rails_disk_service GET      /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#                                update_rails_disk_service PUT      /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#                                     rails_direct_uploads POST     /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
#
# Routes for Blazer::Engine:
#       run_queries POST   /queries/run(.:format)            blazer/queries#run
#    cancel_queries POST   /queries/cancel(.:format)         blazer/queries#cancel
#     refresh_query POST   /queries/:id/refresh(.:format)    blazer/queries#refresh
#    tables_queries GET    /queries/tables(.:format)         blazer/queries#tables
#    schema_queries GET    /queries/schema(.:format)         blazer/queries#schema
#      docs_queries GET    /queries/docs(.:format)           blazer/queries#docs
#           queries GET    /queries(.:format)                blazer/queries#index
#                   POST   /queries(.:format)                blazer/queries#create
#         new_query GET    /queries/new(.:format)            blazer/queries#new
#        edit_query GET    /queries/:id/edit(.:format)       blazer/queries#edit
#             query GET    /queries/:id(.:format)            blazer/queries#show
#                   PATCH  /queries/:id(.:format)            blazer/queries#update
#                   PUT    /queries/:id(.:format)            blazer/queries#update
#                   DELETE /queries/:id(.:format)            blazer/queries#destroy
#         run_check GET    /checks/:id/run(.:format)         blazer/checks#run
#            checks GET    /checks(.:format)                 blazer/checks#index
#                   POST   /checks(.:format)                 blazer/checks#create
#         new_check GET    /checks/new(.:format)             blazer/checks#new
#        edit_check GET    /checks/:id/edit(.:format)        blazer/checks#edit
#             check PATCH  /checks/:id(.:format)             blazer/checks#update
#                   PUT    /checks/:id(.:format)             blazer/checks#update
#                   DELETE /checks/:id(.:format)             blazer/checks#destroy
# refresh_dashboard POST   /dashboards/:id/refresh(.:format) blazer/dashboards#refresh
#        dashboards POST   /dashboards(.:format)             blazer/dashboards#create
#     new_dashboard GET    /dashboards/new(.:format)         blazer/dashboards#new
#    edit_dashboard GET    /dashboards/:id/edit(.:format)    blazer/dashboards#edit
#         dashboard GET    /dashboards/:id(.:format)         blazer/dashboards#show
#                   PATCH  /dashboards/:id(.:format)         blazer/dashboards#update
#                   PUT    /dashboards/:id(.:format)         blazer/dashboards#update
#                   DELETE /dashboards/:id(.:format)         blazer/dashboards#destroy
#              root GET    /                                 blazer/queries#home

require 'sidekiq/web'
Rails.application.routes.draw do
  devise_for :users, skip: [:registrations], controllers: {
    #for killing intercom session
    sessions: 'devise_overridden/sessions'
  }

  get '/dashboard', to: 'home#dashboard'

  # updating last seen onboarding step.
  # it is needed for resuming onboarding on the step where user is left
  post '/onboarding', to: 'onboarding#update'

  #proxy that redirects to postmark website given message id in GET param
  get '/postmark/show', to: 'postmark#show'

  get '/expired-auth-link', to: 'expired_auth_links#show'
  #both methods only for easier testing in local env
  match '/expired-auth-link/send_link', to: 'expired_auth_links#send_link', via: %i[get post]

  #get '/progress/teams', action: :teams, as: :teams_progress
  #TODO find a better place for it
  get '/welcome', to: 'home#welcome_video', as: :welcome_video # step1 upd
  with_options controller: 'multi_step_leader_sign_up' do
    get '/step2', action: :leader_strength_finder
    get '/step3', action: :team_survey_360
    get '/step4', action: :mentorship
  end

  post '/users/reset-password' => 'users#reset_password', as: :user_reset_password
  resources :users, only: %i[show edit update] do
    #TODO these 2 routes seems like in the wrong place. Fix it
    # but where to put it? users#update already does too much
    put 'anonymous_survey_participants' => 'anonymous_survey_participants#update'
  end
  # overriding default devise/registrations#create route. Acceptible for now because we don't have public sign up.
  # user_reset_password POST     /users/reset-password(.:format)
  post '/users' => 'users#create'

  resources :progress_report_recipients, only: %i[create update destroy] # dynamic lists

  resources :anonymous_survey_participants, only: %i[create update destroy] # dynamic lists

  resources :team_members, only: %i[create update destroy] # dynamic lists

  resources :organizational_mentorships, only: %i[create update destroy] do # dynamic lists
    #NOTE: keep in mind that accept link have to stay persistent(present in email links)
    get :accept, on: :member
  end
  get 'user_mentees/:id/accept', to: redirect { |_params, request| "/organizational_mentorships/#{request.params[:id]}/accept?#{request.params.slice(:user_email, :user_token).to_query}" }
  get 'mentorships/:id/accept', to: redirect { |_params, request| "/organizational_mentorships/#{request.params[:id]}/accept?#{request.params.slice(:user_email, :user_token).to_query}" }

  get '/robots.txt' => 'home#robots'

  with_options controller: 'webhooks' do
    post '/webhooks/postmark-bounce', action: :postmark_bounce
  end

  resources :entry_replies, only: %i[create update destroy] do
    member do
      match :toggle_like, via: %i[get post]
    end
  end

  with_options controller: 'profile' do
    match '/profile/billing', action: :billing, via: %i[get post]
    put '/profile/setting_password', action: 'setting_password'
    get '/profile/api', action: :api

    match '/profile/engagement', action: :engagement, via: %i[get post]
    get '/profile/mentorship', action: :mentorship
    get '/profile/team-survey-360', action: :team_survey_360
    get '/profile/accountability', action: :accountability
  end

  resources :leaderbits, only: %i[show index] do
    resources :entries, only: %i[create edit show update destroy]
    resources :boomerangs, only: %i[create]
    get 'start', on: :member
  end
  #TODO
  #NOTE: get is needed as well because accessible via regular a tag link
  match '/challenges/begin-first' => 'leaderbits#begin_first_challenge', via: %i[get post]

  authenticate :user, lambda { |u| u.system_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  authenticate :user, ->(user) { user.system_admin? || user.leaderbits_employee_with_access_to_any_organization? } do
    mount Blazer::Engine, at: "blazer"
  end

  resources :surveys, only: [] do
    match :participate_anonymously, via: %i[get post], on: :member
    get :anonymous_survey_completed, on: :collection

    resources :answers, only: [:create]
  end

  authenticate :user, lambda { |u| u.access_to_admin_interface? } do
    namespace :admin do
      get '/', to: 'home#root', as: :dashboard
      get '/report', to: 'home#report', as: :report
      put '/user-notes', to: 'user_notes#update'
      resources :audits, only: %i[index]
      resources :leaderbits, only: %i[index show new create edit update] do
        # TODO dead code?
        # collection do
        #   post :sort
        # end
      end

      resources :teams, only: %i[index show]
      resources :tags, only: %i[index show edit update]
      resources :surveys, only: %i[index show edit update] do
        resources :questions, only: %i[new create edit update show destroy] do
          collection do
            post :sort
          end
        end
      end
      resources :schedules do #NOTE: all default actions are used
        member do
          post :sort
        end
        member do
          post :clone
          post :add_leaderbit
          post :remove_leaderbit
        end
      end

      #NOTE: all default actions are used
      resources :organizations do
        member do
          post :send_lifetime_progress_report
        end
      end
      resources :organizational_mentorships, only: %i[create destroy]
      resources :users do #NOTE: all default actions are used
        resources :preemptive_leaderbits, only: %i[create] do
          #NOTE: not really collection but we iterate on leaderbit-level instead
          collection do
            delete :destroy_by_leaderbit_id
          end
          member do
            post :sort
          end
        end
        member do
          post :toggle_discard
          get :password_reset
          post :trigger_next_leaderbit_instant_sending
          post :send_lifetime_progress_report
          #post :add_leaderbit_to_preemptive_queue
          #post :sort_preemptive_leaderbits
        end
      end
      resources :vacation_modes, only: [:destroy]
    end
  end

  # NOTE: keep route in sync with unobtrusive_flash_custom_handler.js if you want to change it
  get '/achievement-modal' => 'achievements#show'

  resources :preemptive_leaderbits, only: %i[create]
  resources :vacation_modes, only: %i[create update destroy]

  resources :teams, only: %i[new create edit update]
  get '/company' => 'companies#show'

  resources :settings, only: [] do
    collection do
      get :strength_levels
      patch :strength_levels

      get :analytics
      get :community
    end
  end

  get '/investigation-166012032' => 'investigations#show'

  #custom path for making links look good(e.g. #show action is publicly visible and accessible from mailer templates)
  resources :entry_groups, only: %i[index show], path: 'leaderbit-entries' do
    collection do
      get :joels_responses
    end
    member do
      post :mark_as_read
    end
  end

  resources :entries, only: %i[show edit update create] do
    # TODO: move member actions to leaderbits/entries scope instead. upd - Why? Outdated comment?
    member do
      post :toggle_like
    end
  end

  #NOTE: if you decide to move/rename it you'll need to update config that you pass to ActionCable.createConsumer
  # because "/cable" is ActionCable's default INTERNAL.default_mount_path
  mount ActionCable.server => '/cable'
  root to: "home#root"
end
