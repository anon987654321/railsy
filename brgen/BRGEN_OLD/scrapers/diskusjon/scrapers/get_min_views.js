'use strict';

var cheerio = require('cheerio');

module.exports = function(data, limit, cb) {
  var ret = [],
    $ = cheerio.load(data);

  $('tr.expandable').each(function(i, el) {
    var replies = parseInt($(el).find('.col_f_views li').last().text().split('visn.')[0].split(' ').join(''), 10);

    if(replies >= limit) {
      ret.push($(el).find('a[itemprop="url"]').attr('href'));
    }
  });

  return cb(null, ret);
};

