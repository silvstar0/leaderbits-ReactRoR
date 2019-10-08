# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    add_breadcrumb 'Admin'
    add_breadcrumb 'Tags', %i[admin tags]

    #before_action :set_tag, only: %i[show edit update]

    def index
      @tags = all_global_tag_labels
      authorize User, policy_class: Admin::TagPolicy
    end

    def show
      @label = params[:id]

      @leaderbits = Leaderbit
                      .joins(:tags)
                      .where('leaderbit_tags.label = ?', @label)

      @questions = Question
                     .joins(:tags)
                     .where('question_tags.label = ?', @label)
    end

    def edit
      @tag = LeaderbitTag.where(label: params[:id]).first || QuestionTag.where(label: params[:id]).first
      add_breadcrumb @tag.label, admin_tag_path(@tag)
    end

    def update
      old_tag_name = params[:id]
      new_tag_name = params.dig(:leaderbit_tag, :label) || params.dig(:question_tag, :label)

      count = 0
      count += LeaderbitTag.where(label: old_tag_name).update_all(label: new_tag_name)
      count += QuestionTag.where(label: old_tag_name).update_all(label: new_tag_name)

      unobtrusive_flash.regular type: :notice, message: %("#{old_tag_name}" tags successfully renamed to "#{new_tag_name}". Affected rows: #{count})
      redirect_to admin_tags_path
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(
        :title
      )
    end
  end
end
