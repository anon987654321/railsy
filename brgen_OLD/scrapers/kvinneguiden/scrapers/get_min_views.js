'use strict';

var cheerio = require('cheerio');

module.exports = function(data, limit, cb) {
  var ret = [],
    $ = cheerio.load(data),
    $topics = $('.ipsDataItem');

  $topics.each(function(i, e) {
    var $e = $(e),
      views = parseInt($e.find('.ipsType_light .ipsDataItem_stats_number').text().replace(/[^0-9]+/g, ''), 10);

    if(views >= limit) {
      ret.push($e.find('.ipsDataItem_title a').attr('href'));
    }
  });

  return cb(null, ret);
};

