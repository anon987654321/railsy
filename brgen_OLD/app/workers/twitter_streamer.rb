class TwitterStreamer
  include Sidekiq::Worker

  def perform
    Rails.logger.info("Begin Twitter streaming")
    configure_twitter_client
    user = User.first
  
    @forum = Forem::Forum.find_by_name("Generelt")
 
    # http://gettwitterid.com/

    TweetStream::Client.new.follow(
      # 14407392,  # @btno
      # 358969925, # @btmeninger
      900392084, # @hordalandpoliti
      43525582,  # @forsvarsdep
      80248689,  # @haukeland_no
      17867748,  # @uib
      34259771,  # @uibsnyhetsavis
      124149022, # @studvestno
      179249387, # @bergenbystyre
      89425108,  # @festspillene
      14992973,  # @royksopp
      31620747,  # @brainfeeder
      46436607,  # @plugresearch
      # 26939677,  # @ericandre
      # 26434756,  # @alphapup
      363352400, # @vegardino
      280925842, # @bylvisaker
      # 260308246, # @leoajkic
      26491964   # @standupbergen
    ) do |status|

      # Ignore retweets

      unless status.text.starts_with? "RT"
        Rails.logger.info("Creating new tweet: #{status.text}")
  
        @topic = @forum.topics.build({
          subject: status.text,
          external_media_id: status.id,
          external_media_type: "twitter",
          posts_attributes: [text: status.uri]
        })
 
        @topic.user = user
        @topic.save!
        @topic.update_column(:state, "published")
      end
    end
  end

private
  def configure_twitter_client
    TweetStream.configure do |config|

      # TODO: Move to `secrets.yml`

      config.consumer_key = "oQM83XT6kIcaBoVM1wBmP0bib"
      config.consumer_secret = "udVq8Vx603JW3fmxoxwbleaRcAObUDmSPAz5rOnuwzVVGp9t4t"
      config.oauth_token = "3355714197-wO1FXugi6jX8i9vhWYzG1MnpjuaE3xH1k575ruA"
      config.oauth_token_secret = "xcqv0ErFRAPPmDij5D30BI4sSsT9iHiGcfxLWtiA2cKOI"
      config.auth_method = :oauth
    end
  end
end

