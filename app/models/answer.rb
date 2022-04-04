class Answer < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :answer, presence: true

  before_save :check_correctness

  QUESTION_REGEX = /^(what|where|when|who)/i

  def emoji
    is_correct? ? ":white_check_mark:" : ":x:"
  end

  def is_answer_correct?
    correct_answer = game.answer.gsub(/^(the|a|an) /i, "")
                                .strip
                                .downcase
    sanitized_answer = answer
                      .gsub(/\s+(&nbsp;|&)\s+/i, " and ")
                      .gsub(QUESTION_REGEX, "")
                      .gsub(/^(is|are|was|were|'s|’s|s) /, "")
                      .gsub(/^(the|a|an) /i, "")
                      .gsub(/\?+$/, "")
                      .strip
                      .downcase
    white = Text::WhiteSimilarity.new
    similarity = white.similarity(correct_answer, sanitized_answer)
    correct_answer == sanitized_answer || similarity >= 0.5
  end

  def is_in_question_format?
    answer.strip.match? QUESTION_REGEX
  end

  private

  def check_correctness
    self.is_correct = is_in_question_format? && is_answer_correct?
  end
end
