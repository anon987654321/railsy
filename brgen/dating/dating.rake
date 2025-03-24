# frozen_string_literal: true

require "replicate"
require "faker"

namespace :faker do
  task dating: :environment do
    scraper = Dating::Scraper.new
    scraper.run
  end
end

module Dating
  class Scraper
    ACTIVITY = [
      "looking at the camera",
      "attempting to set a new world record",
      "recreating a scene from a favorite movie",
      "attempting to cook a gourmet meal with random pantry items",
      "building a pillow fort",
      "starting a dance-off in the living room",
      "holding a karaoke competition",
      "learning a magic trick",
      "conducting a DIY science experiment",
      "participating in a home fashion show",
      "hosting a virtual game night",
      "trying to speak a new language",
      "making a homemade music video",
      "attempting a world record for the most cups of coffee consumed in a day",
      "inventing a new type of dance",
      "trying to make their pet internet-famous"
    ].freeze

    def outfit_based_on_gender(gender)
      if gender == "male"
        [
          "streetwear: baggy jeans, oversized graphic tee, and chunky sneakers",
          "luxury casual: designer sweatpants, high-end logo t-shirt, and limited-edition sneakers",
          "edgy: leather pants, graphic tank top, layered chain necklaces, and combat boots",
          "flashy: colorful suit, diamond-encrusted watch, and patent leather loafers",
          "athleisure: branded tracksuit, matching cap, and sporty sneakers",
          "minimalist: black slim-fit jeans, plain white tee, and black leather high-tops",
          "vintage: retro sports jersey, baggy denim jeans, and classic basketball shoes"
        ]
      else
        [
          "edgy: black leather mini skirt, studded crop top, and knee-high boots",
          "glam: sequin jumpsuit, silver stiletto heels, and oversized sunglasses",
          "punk: ripped black jeans, band t-shirt, leather jacket, and combat boots",
          "retro: polka dot midi dress, red patent heels, and cat-eye sunglasses",
          "festival: neon fringe crop top, denim cutoff shorts, and glitter ankle boots",
          "avant-garde: deconstructed blazer, asymmetric skirt, and platform shoes",
          "streetwear: oversized graphic sweatshirt, bike shorts, and chunky sneakers"
        ]
      end.sample
    end

    # Popular techniques in award-winning cinematography
    # https://stable-diffusion-art.com/realistic-people/#Lighting_keywords
    LIGHTING = [
      "three-point lighting",
      "high-key lighting",
      "low-key lighting",
      "chiaroscuro lighting",
      "motivated lighting",
      "natural lighting",
      "practical lighting",
      "backlighting",
      "side lighting",
      "fill lighting"
    ].freeze

    def initialize
      Replicate.configure do |config|
        config.api_token = ENV["REPLICATE_API_KEY"]
      end
    end

    def run
      model = Replicate.client.retrieve_model("mcai/realistic-vision-v2.0")
      version = model.latest_version

      4.times do
        gender = %w[male female].sample

        user = User.create!(
          email: Faker::Internet.email,
          password: Faker::Internet.password(min_length: 8, mix_case: true, special_characters: true),
          first_name: gender == "male" ? Faker::Name.male_first_name : Faker::Name.female_first_name,
          bio: Faker::ChuckNorris.fact,
          age: rand(16..80),
          gender: gender == "male" ? 1 : 0,
          seeking_gender: gender == "male" ? 0 : 1
        )

        inputs = {
          "prompt": "photo of norwegian #{ gender } #{ ACTIVITY.sample }, #{ ['blonde', 'dark blonde', 'brown', 'black', 'red'].sample } hair, wearing #{ outfit_based_on_gender(gender) }, #{ LIGHTING.sample }, DSLR, ultra quality, sharp focus, tack sharp, DOF, film grain, Fujifilm XT3, crystal clear, 8K UHD, highly detailed glossy eyes, high detailed skin, skin pores",
          "negative_prompt": "disfigured, ugly, bad, immature, cartoon, anime, 3d, painting, b&w, nude",
          "width": 512,
          "height": 768,
          "num_outputs": rand(1..4),
          "num_inference_steps": 50,
          "guidance_scale": 7,
          "scheduler": "EulerAncestralDiscrete"
        }

        prediction = version.predict(inputs)
        fetch_prediction(prediction)

        url = prediction.urls["get"]
        add_photo(url, user, "avatar")
        puts url

        sleep 12
      end
    end

    def fetch_prediction(prediction)
      loop do
        prediction.refetch
        break if prediction.finished?

        puts "Sleeping 30 seconds while waiting for image..."
        sleep 30
      end
    end

    def add_photo(url, resource, attachment_type)
      file = URI.open(url, "Authorization" => "Token #{ Replicate.api_token }")
      filename = File.basename(URI.parse(url).path)
      resource.__send__(attachment_type).attach(io: file, filename:)
      resource.save!
    end
  end
end
