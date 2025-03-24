'use strict';

var async = require('async'),
  _ = require('lodash');

var request = require('../../common/request'),
  scrapers = require('../scrapers'),
  getTopics = require('../../common/get_topics')(scrapers);

module.exports = function(o, cb) {
  if(!o['source_forum']) {
    return cb(new Error('Missing source_forum!'));
  }

  var pages = parseInt(o.pages, 10),
    minViews = parseInt(o['min_views'], 10),
    minReplies = parseInt(o['min_replies'], 10),
    root = 'http://forum.kvinneguiden.no/forum/' + o['source_forum'] + '/';

  async.mapSeries(_.range(1, pages + 1), function(page, cb) {
    request(root + '?page=' + page, function(err, data) {
      if(err) {
        return cb(err);
      }

      getTopics({
        data: data,
        minViews: minViews,
        minReplies: minReplies
      }, cb);
    });
  }, function(err, d) {
    if(err) {
      return cb(err);
    }

    cb(null, _.flatten(d));
  });
};

