var cheerio = require('cheerio');

module.exports = function(data, limit, cb) {
  var ret = [],
    $ = cheerio.load(data),
    $topics = $('.ipsDataItem');

  $topics.each(function(i, e) {
    var $e = $(e),
      count = parseInt($e.find('*[itemprop="commentCount"]').text(), 10);

    if(count >= limit) {
      ret.push($e.find('.ipsDataItem_title a').attr('href'));
    }
  });

  return cb(null, ret);
};

