'use strict';

var async = require('async'),
  _ = require('lodash');

var scrapers = require('../scrapers'),
  getTopics = require('../../common/get_topics')(scrapers),
  request = require('../../common/request');

module.exports = function(o, cb) {
  if(isNaN(o.id)) {
    return cb(new Error('Received `NaN` as id'));
  }

  var pages = parseInt(o.pages, 10),
    minViews = parseInt(o['min_views'], 10),
    minReplies = parseInt(o['min_replies'], 10),
    root = 'http://freak.no/forum/forumdisplay.php?f=' + o.id + '&order=desc&page=';

  async.mapSeries(_.range(1, pages + 1), function(page, cb) {
    request(root + page, function(err, data) {
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

