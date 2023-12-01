require 'rails_helper'

RSpec.describe "Main", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /ask" do
    it "fails when there is no question" do
      post "/ask"
      expect(response).to have_http_status(:bad_request)
    end

    it "succeeds when there is a question" do
      question = Question.create!(question: 'test question', answer: 'test answer', context: 'test context')

      expect(AnswerQuestion).to receive(:new).with('test question').and_return -> { question }

      post "/ask", params: { question: 'test question' }
      expect(response).to have_http_status(:success)
      expect(response.body).to eq "{\"id\":#{question.id},\"question\":\"test question\",\"answer\":\"test answer\"}"
    end
  end
end
