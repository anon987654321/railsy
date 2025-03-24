'use strict';

var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    url = $('.next a').attr('href');

  if(url) {
    return cb(null, url);
  }

  cb(new Error('URL not found'));
};

