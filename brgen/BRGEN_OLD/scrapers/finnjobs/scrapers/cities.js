'use strict';

var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    ret = {};

  $('#navigatorForm input[type="checkbox"]:checked').last().parents('li').first().find('a').each(function(i, e) {
    var $e = $(e),
      href = $e.attr('href');

    if(href) {
      ret[$e.text()] = parseHref(href);
    }
  });

  cb(null, ret);
};

function parseHref(str) {
  return str.replace(/\//g, '%2F');
}

