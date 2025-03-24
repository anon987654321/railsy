'use strict';

var async = require('async'),
  set = require('setjs');

module.exports = function(scrapers) {
  return function(o, cb) {
    async.parallel([
      scrapers.get_min_replies.bind(null, o.data, o.minReplies),
      scrapers.get_min_views.bind(null, o.data, o.minViews)
    ], function(err, d) {
      if(err) {
        return cb(err);
      }

      cb(null, Object.keys(set.intersection(set.apply(null, d[0]), set.apply(null, d[1]))));
    });
  };
};

