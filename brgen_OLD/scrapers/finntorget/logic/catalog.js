'use strict';

var async = require('async'),
  _ = require('lodash');

var request = require('../../common/request'),
  scrapers = require('../scrapers');

var URL_PREFIX = 'http://www.finn.no/finn/torget/resultat';

module.exports = function(config, cb) {
  async.waterfall([
    getCategory.bind(null, config.category),
    getTemplate.bind(null, scrapers.counties, config.county),
    getTemplate.bind(null, scrapers.cities, config.city),
    getItemUrls.bind(null, config.pages)
  ], cb);
};

function getCategory(category, cb) {
  request(URL_PREFIX + '?categories=' + category, function(err, data) {
    if(err) {
      return cb(err);
    }

    cb(null, {
      data: data
    });
  });
}

function getTemplate(scraper, match, o, cb) {
  scraper(o.data, function(err, d) {
    if(err) {
      return cb(err);
    }

    var url = d[match];

    if(!url) {
      return cb(new Error('Failed to find match ' + match + ' from ' +
        Object.keys(d).join(', ')));
    }

    request(URL_PREFIX + url, function(err, data) {
      if(err) {
        return cb(err);
      }

      cb(null, {
        data: data,
        url: url
      });
    });
  });
}

function getItemUrls(pages, o, cb) {
  async.mapSeries(_.range(1, pages + 1), function(page, cb) {
    request(URL_PREFIX + o.url + '&page=' + page, function(err, data) {
      if(err) {
        return cb(err);
      }

      scrapers.catalog(data, cb);
    });
  }, function(err, d) {
    if(err) {
      return cb(err);
    }

    cb(null, _.flatten(d));
  });
}

