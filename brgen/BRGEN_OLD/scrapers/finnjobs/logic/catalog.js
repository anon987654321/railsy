'use strict';

var async = require('async'),
  _ = require('lodash');

var scrapers = require('../scrapers'),
  request = require('../../common/request');

var URL_PREFIX = 'http://www.finn.no/finn/job/';

module.exports = function(config, cb) {
  async.waterfall([
    getCategory.bind(null, config.category),
    getTemplate.bind(null, config.category, scrapers.counties, config.county),
    getTemplate.bind(null, config.category, scrapers.cities, config.city),
    getTemplate.bind(null, config.category, scrapers.occupation, config.occupation),
    getItemUrls.bind(null, config.category, config.pages)
  ], cb);
};

function getCategory(category, cb) {
  request(URL_PREFIX + category + '/result', function(err, data) {
    if(err) {
      return cb(err);
    }

    cb(null, {
      data: data
    });
  });
}

function getTemplate(category, scraper, match, o, cb) {
  scraper(o.data, function(err, d) {
    if(err) {
      return cb(err);
    }

    var url = d[match];

    if(!url) {
      return cb(new Error('Failed to find match ' + match));
    }

    request(URL_PREFIX + category + '/result' + url, function(err, data) {
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

function getItemUrls(category, pages, o, cb) {
  async.mapSeries(_.range(1, pages + 1), function(page, cb) {
    var url = URL_PREFIX + category + '/result' + o.url + '&page=' + page;

    request(url, function(err, data) {
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

