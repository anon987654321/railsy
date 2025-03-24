'use strict';

var async = require('async'),
  _ = require('lodash');

var posts = require('../scrapers').posts,
  request = require('../lib/request');

module.exports = function(o, cb) {
  var root = 'http://www.visitoslo.com/no/' + o.category + '/' + o.subcategory + '#';

  async.concatSeries(_.range(1, o.pages + 1), function(page, cb) {
    request(root + page, function(err, data) {
      if(err) {
        return cb(err);
      }

      cb(null, posts(data));
    });
  }, cb);
};

