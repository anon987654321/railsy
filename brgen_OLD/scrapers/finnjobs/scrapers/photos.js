'use strict';

var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    ret = [];

  $('.object-logo').each(function(i, e) {
    var href = $(e).attr('src');

    if(href) {
      ret.push(href);
    }
  });

  cb(null, ret);
};

