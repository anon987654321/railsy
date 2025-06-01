'use strict';

var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var root = 'http://freak.no/forum/',
    $ = cheerio.load(data),
    url = $('.pagenav .alt2').next().find('a').attr('href');

  if(url) {
    return cb(null, root + url);
  }

  cb(new Error('URL not found'));
};

