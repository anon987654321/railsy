'use strict';

var cheerio = require('cheerio');
var lodash = require('lodash');

var request = require('../../common/request');

require('date-utils');

module.exports = function(o, cb) {
  var toDays = parseInt(o.toDays, 10) || 1,
    beginDate = new Date(o.date),
    toDate = new Date(o.date);

  toDate.addDays(toDays);

  var eventsUrl = 'http://www.visitbergen.com/' + o.category +
    '/searchresults?' +
    'stay=' + beginDate.toFormat('YYYY-MM-DD') + '&' +
    'end=' + toDate.toFormat('YYYY-MM-DD');

  if(o.subcategory) {
    eventsUrl += '&cat=' + o.subcategory;
  }

  scrapeEvents(eventsUrl, cb);
};

function scrapeEvents(url, cb) {
  request(url, function(err, body) {
    if(err) {
      return cb(err);
    }

    cb(null, scrapeEventUrls(body));
  });
}

function scrapeEventUrls(data) {
  var $ = cheerio.load(data);

  return lodash.uniq($('.productList .ProductDetail').map(function(i, el) {
    return $(el).attr('href');
    // Drop these lines if this works
    //return 'http://www.visitbergen.com' + $(el).attr('href');
  }).get());
}

module.exports.scrape = scrapeEventUrls;

