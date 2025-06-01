'use strict';

var async = require('async'),
  moment = require('moment');

var request = require('../../common/request'),
  savePhotos = require('../../common/save_photos'),
  scrapers = require('../scrapers');

module.exports = scrape;

function scrape(o, url, cb) {
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
          photos: photos
        });
      });
    });
  });
}

function formatItem(url, config, item, cb) {
  var site = config.site,
    data = item.data;

  savePhotos(item.photos, config, function(err, photos) {
    data.details['source_link'] = url;

    cb(null, {
      'subject': data.subject,
      'details': data.details,
      'address': data.address,
      'contacts': data.contacts,
      'posts_attributes': [{
        'text': formatContent(data),
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

function formatContent(data) {
  var contacts = data.contacts || [],
    text = '';

  // tweak this to get the fields you want from details
  text += '\n' + getFields([
    ['Pris', 'price1'],
    ['Areal', 'size'],
    ['Soverom', 'bedrooms'],
    //['Eieform', 'owner'],
    ['Boligtype', 'type'],
  ], data.details).join('\n');

  text += '\n\n' + contacts.map(getFields.bind(null, [
    ['', 'name'],
    ['Telefon', 'phone'],
    ['Mobil', 'mobile'],
    ['Fax', 'fax'],
    ['', 'url']
  ])).map(function(o) {
    return o.join('\n');
  }).join('\n\n') + '\n';

  return text;
}
module.exports.formatContent = formatContent;

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

