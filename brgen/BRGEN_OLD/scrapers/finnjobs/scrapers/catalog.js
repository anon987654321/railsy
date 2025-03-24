var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    ret = [];

  $('.jobobject a').each(function(i, e) {
    var href = $(e).attr('href');

    if(href) {
      ret.push(href);
    }
  });

  cb(null, ret);
};

