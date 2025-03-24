'use strict';

var _ = require('lodash'),
  async = require('async'),
  moment = require('moment');

var request = require('../../common/request'),
  savePhotos = require('../../common/save_photos');

var scrapers = require('../scrapers');

module.exports = main;

function main(o, url, cb) {
  console.log('Scraping ' + url);

  async.waterfall([
    getItem.bind(null, url),
    formatItem.bind(null, url, o)
  ], cb);
}

function getItem(url, cb) {
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
          'photos_attributes': photos
        });
      });
    });
  });
}

function formatItem(url, config, item, cb) {
  var site = config.site,
    data = item.data;

  savePhotos(item.photos, config, function(err, photos) {
    cb(null, {
      'subject': data.title,
      'address': data.address,
      'posts_attributes': [{
        'text': data.description + '\n\n' + formatContent(url, data),
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

function formatContent(url, data) {
  var titles = data.titles && data.titles.map(getFields.bind(null, [
    ['', 'name'],
    ['', 'position'],
    ['Telefon', 'phone']
  ]));

  if(!_.isArray(titles)) {
    return console.error('Tried to scrape', url, data, 'but got something else than array!');
  }

  titles = titles.reduce(function(a, b) {
    return a.concat(b);
  }, []).join('\n');

  if(titles) {
    titles += '\n\n';
  }

  return titles + getFields([
    ['Firma', 'company'],
    ['Tittel', 'jobTitle'],
    ['Tiltredelse', 'starts'],
    ['Sektor', 'sector'],
    ['Varighet', 'duration'],
    ['Stillinger', 'positions']
  ], data).join('\n');
}
main.formatContent = formatContent;

function getFields(configuration, data) {
  return configuration.map(function(o) {
    var k = o[0],
      v = o[1];

    if(data[v]) {
      if(k) {
        return k + ': ' + data[v];
      }

      return data[v];
    }
  }).filter(id);
}

function id(a) { return a; }

