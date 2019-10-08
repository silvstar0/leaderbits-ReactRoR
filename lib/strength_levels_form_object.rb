# frozen_string_literal: true

class StrengthLevelsFormObject
  DEFAULT_VALUE = 50

  include ActiveModel::Model

  module Levels
    CRAFT = 'craft'
    CULTURE = 'culture'
    LEARNING = 'learning'
    ONE_ON_ONE = 'one_on_one'
    PROBLEM_SOLVING = 'problem_solving'
    GROWING = 'growing'
    MANAGING = 'managing'
    VISIONARY = 'visionary'
    BUSINESS = 'business'
    COMMUNICATION = 'communication'
    DISCIPLINE = 'discipline'
    PROCESS = 'process'
    TEAM_STRUCTURE = 'team_structure'
    TEAM_MANAGEMENT = 'team_management'
    STRATEGY = 'strategy'
    TIME_MANAGEMENT = 'time_management'
    STRESS = 'stress'
    CREATIVITY = 'creativity'
    PERSONAL_DEVELOPMENT = 'personal_development'
    PERSONAL_CARE = 'personal_care'

    ALL = [
      CRAFT,
      CULTURE,
      LEARNING,
      ONE_ON_ONE,
      PROBLEM_SOLVING,
      GROWING,
      MANAGING,
      VISIONARY,
      BUSINESS,
      COMMUNICATION,
      DISCIPLINE,
      PROCESS,
      TEAM_STRUCTURE,
      TEAM_MANAGEMENT,
      STRATEGY,
      TIME_MANAGEMENT,
      STRESS,
      CREATIVITY,
      PERSONAL_DEVELOPMENT,
      PERSONAL_CARE,
    ].freeze
  end

  attr_accessor(*Levels::ALL)

  # @param [ActiveRecord::Relation] user's existing user_strength_levels activerecord relation
  def initialize(user_strength_levels)
    Levels::ALL.each do |symbol_name|
      # TODO-low needs refactoring. Too many SQL queries. BUT this page is very rarely used.
      symbol_value = user_strength_levels.find { |level| level.symbol_name == symbol_name.to_s }&.value || DEFAULT_VALUE
      send("#{symbol_name}=", symbol_value)
    end
  end

  def model_name
    OpenStruct.new(param_key: self.class.param_key)
  end

  def self.param_key
    :strength_levels
  end
end
