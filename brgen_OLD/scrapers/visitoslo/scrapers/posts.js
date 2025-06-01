'use strict';

var cheerio = require('cheerio');

module.exports = function(data) {
  var root = 'http://www.visitoslo.com',
    $ = cheerio.load(data),
    ret = [];

  $('.preloader-wrapper li > .link-icon').each(function(i, el) {
    ret.push(root + $(el).attr('href'));
  });

  return ret;
};

