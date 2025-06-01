'use strict';

var async = require('async'),
  request = require('request');

var url = process.env['SCRAPERS_HOST'] || 'http://localhost:3000';

module.exports = function(o, results, cb) {
  if(results) {
    if(Array.isArray(results)) {
      async.eachSeries(results, postResult.bind(null, o), cb);
    }
    else {
      postResult(o, results, cb);
    }
  }
};

function postResult(o, result, cb) {
  request.post(url + '/api/scraper/v1/topics', {
    qs: {
      'access_token': o.token
    },
    json: {

      // Passed as a parameter to Spyder

      'forum_name': o['brgen_forum'],
      site: o.site,
      topic: result
    }
  }, cb);
}

