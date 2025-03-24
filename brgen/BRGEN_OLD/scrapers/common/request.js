'use strict';

var extend = require('util')._extend,
  request = require('request'),
  _ = require('lodash');

module.exports = function(url, o, cb) {
  if(_.isPlainObject(o)) {
    o = extend(extend({}, o), {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36'
      }
    });

    request(url, o, function(err, res, body) {
      cb(err, body);
    });
  } else {
    cb = o;

    request(url, function(err, res, body) {
      cb(err, body);
    });
  }
};

