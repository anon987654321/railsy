var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    ret = [];

  $('#albumPhotos .albumPhoto img').each(function(i, e) {
    var href = $(e).attr('data-src');

    if(href) {
      ret.push(href);
    }
  });

  cb(null, ret);
};

