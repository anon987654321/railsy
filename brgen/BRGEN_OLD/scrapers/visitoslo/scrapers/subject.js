'use strict';

var cheerio = require('cheerio');

module.exports = function scrape(data) {
  var $ = cheerio.load(data);

  return $('h1.l-top-gutter').text();
};

