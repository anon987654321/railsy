require "rails_helper"

RSpec.describe TwitterStreamer, type: :worker do
  describe "Twitter stream worker" do
    before(:each) do
      TweetStream.configure do |config|
        config.consumer_key = "abc"
        config.consumer_secret = "def"
        config.oauth_token = "123"
        config.oauth_token_secret = "456"
      end
      @client = TweetStream::Client.new

      @stream = double(
        "EM::Twitter::Client",
        :connect => true,
        :unbind => true,
        :each => true,
        :on_error => true,
        :on_max_reconnects => true,
        :on_reconnect => true,
        :connection_completed => true,
        :on_no_data_received => true,
        :on_unauthorized => true,
        :on_enhance_your_calm => true,
        :on_close => true
      )
      allow(EM).to receive(:run).and_yield
      allow(EM::Twitter::Client).to receive(:connect).and_return(@stream)

      @response = {"id" => 123, "user" => {"screen_name" => "monkey"}, "text" => "Sample Tweet"}
    end

    it "filters tweets and creates topics" do
      expect(@stream).to receive(:each).and_yield(@response.to_json)

      TwitterStreamer.new.perform

      @forum = Forem::Forum.find_by_name("Generelt")
      photos = @forum.topics.where(external_media_type: "twitter").order(:external_media_id)

      expect(photos.length).to eq(1)
      expect(photos[0].external_media_id).to eq("123")
    end
  end
end
