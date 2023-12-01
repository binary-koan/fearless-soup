class Question < ApplicationRecord
  validates :question, :answer, :context, presence: true
  validates :question, uniqueness: true
end
