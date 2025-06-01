'use strict';

var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    ret = {};

  // get rid of counties
  $('.mrn.mvn').remove();

  $('.taxonomy-label').each(function(i, e) {
    var $e = $(e);
    var location = $e.find('.neutral').attr('id').split('count-location-')[1];

    ret[$e.text().split('(')[0].trim()] = location;
  });

  cb(null, ret);
};

