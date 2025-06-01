'use strict';

var moment = require('moment');

var request = require('../lib/request'),
  savePhotos = require('../../common/save_photos'),
  scrape = require('../scrapers');

module.exports = function(o, url, cb) {
  console.log('Scraping ' + url);

  request(url, function(err, body) {
    if(err) {
      return cb(err);
    }

    savePhotos(scrape.images(body), o, function(err, photos) {
      scrapeEventData(o.site, url, photos, body, cb);
    });
  });
};

function scrapeEventData(site, url, photos, data, cb) {
  scrape.text(data, function(err, text) {
    cb(null, {
      'subject': scrape.subject(data),
      'posts_attributes': [{
        'text': text,
        'photos_attributes': photos,
        'scraped_at': moment().utc().format(),
        'sources': [
          {
            'name': site,
            'url': url
          }
        ]
      }],
      'address': scrape.address(data),
      'start_date': scrape.date.start(data),
      'end_date': scrape.date.end(data)
    });
  });
}

module.exports.scrape = scrapeEventData;

