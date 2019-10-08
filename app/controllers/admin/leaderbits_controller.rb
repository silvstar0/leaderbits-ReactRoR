# frozen_string_literal: true

module Admin
  class LeaderbitsController < BaseController
    protect_from_forgery except: [:sort]

    add_breadcrumb 'Admin'
    add_breadcrumb 'LeaderBits', %i[admin leaderbits]

    before_action :set_leaderbit, only: %i[show edit update destroy]

    def index
      @leaderbits = Leaderbit
                      .yield_self(&method(:search_clause))
                      .yield_self(&method(:specific_ids_if_specified))
                      .order(order_by[:value])

      authorize [:admin, Leaderbit]
    end

    def show
      authorize [:admin, @leaderbit]
    end

    def new
      authorize [:admin, Leaderbit]

      @leaderbit = Leaderbit.new(user_action_title_suffix: Leaderbit::DEFAULT_USER_ACTION_TITLE_SUFFIX)
      @leaderbit.name = "Challenge: "
      @leaderbit.active = true if current_user.can_make_leaderbit_active?
    end

    def create
      authorize [:admin, Leaderbit]
      create_leaderbit = Admin::CreateLeaderbit.new
      create_leaderbit.with_step_args(notify_joel_if_leaderbit_is_inactive: [current_user: current_user]).call(params.permit!.to_h) do |result|
        result.success do |leaderbit|
          redirect_to [:admin, leaderbit], notice: 'LeaderBit successfully created.'
        end
        result.failure :validate do |leaderbit|
          @leaderbit = leaderbit

          render :new, alert: 'LeaderBit could not be created.'
        end
      end
    end

    def edit
      authorize [:admin, @leaderbit]

      add_breadcrumb @leaderbit.name, admin_leaderbit_path(@leaderbit.to_param)
    end

    def update
      authorize [:admin, @leaderbit]

      add_breadcrumb @leaderbit.name, admin_leaderbit_path(@leaderbit.to_param)

      Admin::UpdateLeaderbit.new.call(params.permit!.to_h) do |result|
        result.success do |leaderbit|
          redirect_to [:admin, leaderbit], notice: 'LeaderBit successfully updated.'
        end
        result.failure :validate do |leaderbit|
          @leaderbit = leaderbit

          render :edit, alert: 'LeaderBit could not be updated.'
        end
      end
    end

    private

    def specific_ids_if_specified(relation)
      if params[:leaderbit_ids].present?
        relation.where(id: params[:leaderbit_ids].split(','))
      else
        relation
      end
    end

    def search_clause(relation)
      if params[:query].present?
        found_in_names = relation.fuzzy_search(name: params[:query])
        # in else condition it performs OR check
        # see docs at https://github.com/textacular/textacular
        found_in_names.present? ? found_in_names : relation.basic_search({ desc: params[:query], body: params[:query] }, false)
      else
        relation
      end
    end

    def set_leaderbit
      @leaderbit = Leaderbit.find(params[:id])
    end

    #TODO move this logic into dry-transaction interactors
    # def leaderbit_params
    #   params.require(:leaderbit).permit(
    #     :name,
    #     :desc,
    #     :video_cover,
    #     :entry_prefilled_text,
    #     :url,
    #     :body,
    #     :active,
    #     :schedule
    #   )
    # end
  end
end
