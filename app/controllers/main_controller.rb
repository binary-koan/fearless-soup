class MainController < ApplicationController
  def index
  end

  def ask
    question = AnswerQuestion.new(params[:question]).call

    render json: question.as_json(only: [:id, :question, :answer])
  end
end
