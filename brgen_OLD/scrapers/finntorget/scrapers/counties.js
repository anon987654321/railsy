var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    ret = {};

  $('#navigatorArea .nav-link a').each(function(i, e) {
    var $e = $(e),
      href = $e.attr('href');

    if(href) {
      ret[$e.text()] = href;
    }
  });

  cb(null, ret);
};

