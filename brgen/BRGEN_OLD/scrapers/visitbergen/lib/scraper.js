'use strict';

var cheerio = require('cheerio'),
  moment = require('moment');

var request = require('../../common/request'),
  savePhotos = require('../../common/save_photos'),
  scrape = require('../scrapers');

module.exports = function(o, url, cb) {
  // #456
  if(url.indexOf('http://www.visitbergen.com') !== 0) {
    url = 'http://www.visitbergen.com' + url;
  }

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
  var $ = cheerio.load(data);

  scrape.text(data, function(err, text) {
    if(err) {
      return cb(err);
    }

    cb(null, {
      'subject': replaceRN($('h1').text()),
      'posts_attributes': [{
        'text': text,
        'photos_attributes': photos,
        'scraped_at': moment().utc().format(),
        'sources': [ // note that source link is passed here instead of details!
          {
            'name': site,
            'url': url
          }
        ]
      }],
      'details': scrape.details(data),
      'address': scrape.address(data),
      'start_date': scrape.date.start(data),
      'end_date': scrape.date.end(data)
    });
  });
}

module.exports.scrape = scrapeEventData;

function replaceRN(str, replacer) {
  replacer = replacer || '';

  return str.replace(/\r\n[ ]+/g, replacer).replace('\u00a0', replacer).trim();
}

