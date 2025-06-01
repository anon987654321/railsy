require "rails_helper"

RSpec.describe RealtimeController, type: :controller do
  describe "POST /twitter_stream" do
    it "triggers async streaming from Twitter" do
      post :twitter_stream, { format: :json }

      expect(response).to have_http_status(200)
    end
  end
end
