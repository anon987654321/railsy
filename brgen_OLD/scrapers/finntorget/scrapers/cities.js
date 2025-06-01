var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    ret = {};

  $('#navigatorArea input:checked').parents('li').first().find('label[data-fth-event="search_navigator_area_municipality"] a').each(function(i, e) {
    var $e = $(e),
      href = $e.attr('href');

    if(href) {
      ret[$e.text()] = href;
    }
  });

  cb(null, ret);
};

