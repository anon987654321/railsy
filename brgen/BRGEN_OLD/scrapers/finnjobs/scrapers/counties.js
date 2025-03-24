'use strict';

var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    ret = {};

  $('*[data-automation-id="geo_location_navigator"] ul ul a').each(function(i, e) {
    var $e = $(e),
      href = $e.attr('href');

    if(href) {
      ret[$e.text()] = href;
    }
  });

  cb(null, ret);
};

