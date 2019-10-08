# frozen_string_literal: true

String.class_eval do
  def possessive
    return self if empty?

    self + (self[-1, 1] == 's' ? Possessive::APOSTROPHE_CHAR : Possessive::APOSTROPHE_CHAR + "s")
  end
end

#condition fixes rubocop annotate warning: already initialized constant Possessive::APOSTROPHE_CHAR
unless defined?(Possessive)
  module Possessive
    APOSTROPHE_CHAR = '’'
  end
end
