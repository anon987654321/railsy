'use strict';

var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data);
  var ret = $('.imagecontainer .crop-landscape').attr('srcset').split(', ').map(function(o) {
    return o.split(' ')[0];
  });

  cb(null, ret);
};

