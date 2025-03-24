'use strict';

var cheerio = require('cheerio');

module.exports = function(data, limit, cb) {
  var root = 'http://freak.no/forum/showthread.php?t=',
    ret = [],
    $ = cheerio.load(data);

  // Remove redundant spans (icons and such)

  $('span').remove();

  $('#threadslist tbody').each(function(i, el) {

    // Only tables with threads have ids

    if(!el.attribs.id) {
      return;
    }

    $(el).find('tr').each(function(i, el) {
      var tds = $(el).find('td'),
        replies = parseInt($(tds[4]).find('a').text().replace('.', ''), 10);

      if(replies >= limit) {
        ret.push(root + $(tds[2]).find('a').first().attr('href').split('=').slice(-1)[0]);
      }
    });
  });

  return cb(null, ret);
};

