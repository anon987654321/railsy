'use strict';

var cheerio = require('cheerio'),
  getText = require('../../common/get_text');

module.exports = function scrape(data, cb) {
  var $ = cheerio.load(data);

  // Cheerio won't detect paragraphs inside paragraphs, so find via parent instead
  getText($, $($('h1:contains("Om")').parent().find('p')[1]), false, cb);
};

