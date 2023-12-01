class MainController < ApplicationController
  def index
    @question = Question.find_by(id: params[:id])
  end

  def ask
    question = AnswerQuestion.new(params.require(:question).strip).call

    render json: question.as_json(only: [:id, :question, :answer])
  end

  def db
    @questions = Question.all.order(ask_count: :desc)
  end
end
