'use strict';

var async = require('async'),
  moment = require('moment');

var request = require('../../common/request'),
  savePhotos = require('../../common/save_photos'),
  scrapers = require('../scrapers');

module.exports = scraper;

function scraper(o, url, cb) {
  console.log('Scraping ' + url);

  async.waterfall([
    getItem.bind(null, request, url),
    formatItem.bind(null, o)
  ], cb);
}

function getItem(request, url, cb) {
  request(url, function(err, body) {
    if(err) {
      return cb(err);
    }

    scrapers.item(body, function(err, itemData) {
      if(err) {
        return cb(err);
      }

      scrapers.photos(body, function(err, photos) {
        cb(null, {
          url: url,
          data: itemData,
          photos: photos
        });
      });
    });
  });
}
scraper.getItem = getItem;

function formatItem(config, item, cb) {
  var site = config.site,
    data = item.data;

  savePhotos(item.photos, config, function(err, photos) {
    cb(null, {
      'subject': data.title,
      'posts_attributes': [{
        'text': data.description + '\n' + data.generalInfo + '\n' + data.phone,
        'photos_attributes': photos,
        'scraped_at': moment().utc().format(),
        'sources': [
          {
            'name': site,
            'url': item.url

          }
        ]
      }]
    });
  });
}

