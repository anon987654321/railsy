'use strict';

var cheerio = require('cheerio'),
  extract = require('annostring').extract;

module.exports = function(data) {
  var $ = cheerio.load(data),
    $e = $('.address address span');

  return {
    address: $e.slice(0, 1).map(function(i, e) {
      return $(e).text();
    }).get().join(' '),
    zip: $e.slice(1).map(function(i, e) {
      return $(e).text();
    }).get().join(' ')
  };
}
