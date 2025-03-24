# frozen_string_literal: true

require "ferrum"
require "open-uri"
require "addressable/uri"
# require "tesseract-ocr"
# require "pry"

AFFILIATE_ID = "brgen0a-20"

INFLUENCERS = [
  {
    url: "https://amazon.com/shop/mik.zenon",
    country: "United States"
  }, {
    url: "https://amazon.com/shop/theohiogirljaz",
    country: "United States"
  }, {
    url: "https://amazon.co.uk/shop/mik.zenon",
    country: "United Kingdom"
  }
]

namespace :scrape do
  task amazon: :environment do
    class Scraper
      def get_seller_lists(url)
        $browser = Ferrum::Browser.new(
          base_url: "https://#{ Addressable::URI.parse(url).domain }",
          slowmo: 2,
          timeout: 60,
          process_timeout: 30
          # Ferrum::TimeoutError
          # Ferrum::ProcessTimeoutError
        )

        $useragent = USERAGENTS.sample
        $browser.headers.set("User-Agent" => $useragent)

        $browser.go_to(url)
        puts $browser.current_url
        humanize
        # scroll_to_bottom

        $browser.at_css(".list-container").css(".a-link-normal").each do |list|
          list_url = list.attribute("href")

          get_product_links(list_url)
        end
      end

      def get_product_links(list_url)
        $browser.go_to(list_url)
        puts $browser.current_url
        humanize
        # scroll_to_bottom

        product_paths = []

        $browser.at_css("#list-item-container").css(".single-list-item > a").each do |product|
          product_path = product.attribute("href")

          product_paths << product_path
        end

        # Remove duplicates
        # product_paths = product_paths.uniq

        puts product_paths
        scrape_and_create_products(product_paths)
      end

      def scrape_and_create_products(product_paths)
        product_paths.each do |product_path|
          $browser.go_to(product_path)
          puts $browser.current_url
          humanize
          # scroll_to_bottom

          # Go to next product
          if $browser.at_css("#outOfStock").present?
            puts "Out of stock, skipping..."
            next
          end

          # Turn breadcrumbs into taxons
          taxonomy = Spree::Taxonomy.find_or_create_by!(name: "Main")

          taxon_ids = []
          taxons = $browser.at_css(".a-breadcrumb")
          if taxons.present?
            taxons.css(".a-link-normal").each do |taxon|
              taxon = taxon.text.strip

              created_taxon = Spree::Taxon.find_or_create_by!(
                name: taxon,
                taxonomy:
              )
              puts created_taxon.name

              taxon_ids << created_taxon.id
            end
          else
            puts "No taxons, skipping..."
            next
          end

          # Stock samples

          Spree::Sample.load_sample("shipping_categories")
          Spree::Sample.load_sample("tax_categories")

          shipping_category = Spree::ShippingCategory.find_by_name!("Default")
          tax_category = Spree::TaxCategory.find_by_name!("Default")

          # Options and variants

          values = []

          def set_options(type, value, values)
            created_type = Spree::OptionType.find_by_name(type)
            unless created_type.present?
              created_type = Spree::OptionType.create!(
                name: type,
                presentation: type
              )
              puts "Created OptionType: #{ created_type.name }"
            end

            created_value = Spree::OptionValue.find_by_name(value)
            return if created_value.present?

            created_value = Spree::OptionValue.create!(
              name: value,
              presentation: value,
              option_type: created_type
            )
            puts "Created OptionType for #{ created_type.name }: #{ created_value.name }"

            # Write to array for product creation later on
            values << created_value
          end

          options_table = $browser.at_css("#productOverview_feature_div table")
          if options_table.present?
            options_table.css("tr").each do |row|
              type = row.at_css("td:nth-of-type(1) span").text.strip
              value = row.at_css("td:nth-of-type(2) span").text.strip

              set_options(type, value, values)
            end
          else
            puts "No options, skipping..."
          end

          # options_form = $browser.at_css("#twister_feature_div form")
          # if options_form.present?
          #   options_form.css(".a-row").each do |row|
          #     type = row.at_css(".a-form-label").text.strip.gsub!(/[^0-9A-Za-z]/, "")
          #     value = row.at_css(".selection").text.strip
          #
          #     set_options(type, value, values)
          #   end
          # end

          name = $browser.at_css("#title span").text.strip

          # Remove everything after commas, dashes, slashes and pipes
          name = name.sub(/,.*/, "")
          name = name.sub(/ - .*/, "")
          name = name.sub(%r{./ .*}, "")
          name = name.sub(/.\| .*/, "")

          price = $browser.at_css(".a-price .a-offscreen")
          if price.present?
            price = price.text.strip
          else
            puts "No price, skipping..."
          end

          description = []
          $browser.at_css("#feature-bullets").css("li:not(#replacementPartsFitmentBullet)").each do |bullet|
            description << bullet.text.strip
          end

          # Join into newline-separated string
          description = description.join("\n\n").to_s

          # Monetize link
          referral_url = referralize($browser.current_url, AFFILIATE_ID)

          if Spree::Product.find_by_name(name)
            puts "Product exists, skipping..."
            next
          else
            begin
              created_product = Spree::Product.create!(
                name:,
                price:,
                description:,
                available_on: Time.current,
                shipping_category:,
                tax_category:,
                taxon_ids:,
                affiliate: true,
                referral_url:
              )
              puts created_product.name
            rescue ActiveRecord::RecordInvalid
              next
            end

            created_product.variants.create(
              option_values: values,
              sku: rand(100_000)
            )

            created_product.variants.each do |variant|
              thumbnails = $browser.at_css("#altImages")
              thumbnails.css("li.imageThumbnail").each do |thumbnail|
                # Click each thumbnails in order for their photos to appear in DOM
                thumbnail.at_css("input.a-button-input").click
              end

              images = $browser.at_css("#main-image-container")
              images.css("li.image").each do |image|
                # Get hi-res photos
                image_url = image.at_css("img").attribute("data-old-hires")

                if image_url.present?
                  downloaded_image = URI.open(image_url, "User-Agent" => $useragent)

                  # Do not include messy images with text
                  # text = Tesseract::Engine.new(downloaded_image).text

                  # if text.empty?
                  File.open(downloaded_image) do |file|
                    variant.images.create!(attachment: file)
                  end
                  puts "Saved #{ image_url }"
                  # else
                  #   puts "#{ image_url } has text, skipping..."
                  #   next
                  # end
                else
                  puts "No image, skipping..."
                  next
                end
              end
            end
          end
        end
      end

      def humanize
        delay = rand(2..8)
        puts "Sleeping #{ delay } seconds..."
        sleep delay

        $browser.mouse.move(x: rand(0..1024), y: rand(0..768))
      rescue Ferrum::TimeoutError
        puts "Timeout error, rescuing..."
      end

      def scroll_to_bottom
        loop do
          height = $browser.evaluate("document.documentElement.offsetHeight")

          puts "Scrolling to the bottom of the page (#{ height }px)..."

          $browser.mouse.scroll_to(0, height)
          new_height = $browser.evaluate("document.documentElement.offsetHeight")

          if height == new_height
            puts "Bottom reached"
            break
          end
        end
      end

      # https://github.com/henrik/delishlist.com/blob/master/lib/amazon_referralizer.rb

      def referralize(url, tag)
        asin = /[A-Z0-9]{10}/
        referral_id = /\w+-\d\d/

        url = url.to_s

        if %r{^https?://(.+\.)?(amazon\.|amzn\.com\b)}i.match?(url)
          url.sub!(%r{\b(#{ asin })\b(/#{ referral_id }\b)?}, "\\1")
          url.gsub!(/&tag=#{ referral_id }\b/, "")
          url.gsub!(/\?tag=#{ referral_id }\b/, "?")
          url.sub!(/\?$/, "")
          url.sub!(/\?&/, "?")

          separator = url.include?("?") ? "&" : "?"

          [url, "tag=#{ tag }"].join(separator)
        else
          url
        end
      end
    end

    # Popular user-agents
    # http://browser-info.net/useragents
    USERAGENTS = [
      "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.85 Safari/537.36",
      "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:34.0) Gecko/20100101 Firefox/34.0",
      "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0",
      "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
      "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/5.0)",
      "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53 (compatible; bingbot/2.0; http://www.bing.com/bingbot.htm)",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; Media Center PC",
      "Mozilla/5.0 (Windows NT 6.2; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0",
      "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:30.0) Gecko/20100101 Firefox/30.0",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko",
      "Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko",
      "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
      "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0",
      "Mozilla/5.0 (iPad; U; CPU OS 5_1 like Mac OS X) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B367 Safari/531.21.10 UCBrowser/3.4.3.532",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; FSL 7.0.6.01001)",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; FSL 7.0.7.01001)",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; FSL 7.0.5.01003)",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0",
      "Mozilla/5.0 (Windows NT 5.1; rv:13.0) Gecko/20100101 Firefox/13.0.1",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:11.0) Gecko/20100101 Firefox/11.0",
      "Mozilla/5.0 (Windows NT 5.1; rv:13.0) Gecko/20100101 Firefox/13.0.1",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:13.0) Gecko/20100101 Firefox/13.0.1",
      "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)",
      "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
      "Opera/9.80 (Windows NT 5.1; U; en) Presto/2.10.289 Version/12.01",
      "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)",
      "Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1",
      "Mozilla/5.0 (Windows NT 6.1; rv:5.0) Gecko/20100101 Firefox/5.02",
      "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1"
    ]

    # --

    scrape = Scraper.new

    INFLUENCERS.each do |seller_page|
      scrape.get_seller_lists(seller_page[:url])
    end
  end
end
