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
    root = 'http://www.diskusjon.no/index.php?showforum=' + o.id + '&prune_day=100&sort_by=Z-A&sort_key=last_post&topicfilter=all&page=';

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

