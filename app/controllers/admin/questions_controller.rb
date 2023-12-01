class Admin::QuestionsController < ApplicationController
  def index
    start, finish = params[:range] ? JSON.parse(params[:range]) : [0, 10]
    sort_field, order = params[:sort] ? JSON.parse(params[:sort]) : ["created_at", "DESC"]

    scope = Question.all.order(sort_field => order)

    response.headers['Content-Range'] = "questions #{start}-#{finish + 1}/#{scope.count}"

    render json: scope.offset(start).limit(finish + 1 - start).map(&:as_json)
  end

  def show
    render json: Question.find(params[:id]).as_json
  end

  def destroy
    question = Question.find(params[:id])
    question.destroy!
    render json: question.as_json
  end
end
