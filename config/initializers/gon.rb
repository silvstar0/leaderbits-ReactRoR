# frozen_string_literal: true

# try to name everything so that related code is greppable
Gon.global.Question = { 'Types' => {
  'SINGLE_TEXTBOX' => Question::Types::SINGLE_TEXTBOX,
  'COMMENT_BOX' => Question::Types::COMMENT_BOX,
  'SLIDER' => Question::Types::SLIDER
} }
