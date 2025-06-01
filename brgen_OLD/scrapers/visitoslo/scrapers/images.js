'use strict';

var cheerio = require('cheerio');

module.exports = function(data) {
  var $ = cheerio.load(data),
    $thumb = $('.pager-container .pager-item img');

  if($thumb.length) {
    return $thumb.map(function(i, el) {
      return $(el).attr('src');
    }).get();
  }
};

