var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var prefix = 'http://www.finn.no/finn/torget/',
    $ = cheerio.load(data),
    ret = [];

  $('.photoframe a').each(function(i, e) {
    var href = $(e).attr('href');

    if(href) {
      ret.push(prefix + href);
    }
  });

  cb(null, ret);
};

