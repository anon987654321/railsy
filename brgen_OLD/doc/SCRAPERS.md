
# Scrapers

[https://github.com/bebraw/spyder](https://github.com/bebraw/spyder)

## Install

    doas npm install spyder -s

    cd scrapers/
    npm install

## Run

Go to `rails console` or `rails console production`, generate a new API key and add it to `.apikeys`:

    ApiKey.create!

Complete set of run commands for each scraper can be found in `method_<scraper>.rb`. Otherwise refer to `spyder_config.js` for available switches.

The main script `run_all.rb` is launched inside a screen on reboot using [Whenever](https://github.com/javan/whenever), so to resume it type `screen -r scrapers`.

# Demo server

## Install

    cd scrapers/demo_server/
    npm install

## Run

Terminal 1:

    export SCRAPERS_API_KEY="demo"
    export SCRAPERS_HOST"http://localhost:3000"
    cd scrapers/demo_server/
    ./serve.js

Terminal 2:

    export SCRAPERS_API_KEY="demo"
    export SCRAPERS_HOST"http://localhost:3000"
    cd scrapers/
    spyder ...

## Tests

    cd scrapers/<scraper>/
    node tests

# Misc

The API accepts HTTP POST requests in JSON for new posts:

    curl http://localhost:3000/api/scraper/v1/topics \
      -H "Accept: application/json" \
      -H "Content-type: application/json" \
      -X POST
      -d '{
        "forum_id": "konserter-fester",
        "source": "visitbergen",
        "topic": {
          "subject": "This is sample post 1",
          "posts_attributes": [
            {
              "text": "This is sample text 1"
            }
          ]
        }
      }'

Photos need to be passed as `original_photos`, `processed_photos` and `filter_data`.

## Sample data
```
{
  "forum_name" => "Konserter, fester",
  "source" => "VisitBergen",
  "topic" => {
    "subject" => "Sample subject",
    "posts_attributes" => [
     {
       "text"=>"Sample text",
       "photos_attributes" => [
         {
           "original_photo" => "original_photo_path",
           "processed_photo" => "processed_photo_path"
          }
        ]
      }
    ],
    "start_date" => "Tue, 15 Jul 2014 18:30:00 GMT",
    "end_date" => "Sat, 14 Dec 2565 18:30:00 GMT",
  },
  "access_token" => "58fc5f63fd556c7311e11f03b04d33ad"
}
```

