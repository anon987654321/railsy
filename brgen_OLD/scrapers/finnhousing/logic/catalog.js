'use strict';

var async = require('async'),
  _ = require('lodash');

var scrapers = require('../scrapers'),
  request = require('../../common/request');

var URL_PREFIX = 'http://m.finn.no/realestate/';

module.exports = function(config, cb) {
  async.waterfall([
    getCategory.bind(null, config.category),
    // it would be possible to skip county/city if needed. now this uses
    // the old logic and both are passed to the scraper
    getTemplate.bind(null, scrapers.counties, config.county),
    getTemplate.bind(null, scrapers.cities, config.city),
    getItemUrls.bind(null, config.pages)
  ], cb);
};

function getCategory(category, cb) {
  request(URL_PREFIX + category + '/search.html', function(err, data) {
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

    var url = 'http://m.finn.no/realestate/homes/search.html?location=' + d[match];

    if(!url) {
      return cb(new Error('Failed to find match ' + match));
    }

    request(url, function(err, data) {
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
    request(o.url + '&page=' + page, function(err, data) {
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

