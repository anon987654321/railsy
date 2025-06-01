var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var prefix = 'http://m.finn.no',
    $ = cheerio.load(data),
    ret = [];

  $('.view-list .flex-area .flex-unit a').each(function(i, e) {
    var href = $(e).attr('href');

    if(href) {
      ret.push(prefix + href);
    }
  });

  cb(null, ret);
};

