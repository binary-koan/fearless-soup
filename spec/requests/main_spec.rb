require 'rails_helper'

RSpec.describe "Mains", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /ask" do
    it "returns http success" do
      post "/ask"
      expect(response).to have_http_status(:success)
    end
  end
end