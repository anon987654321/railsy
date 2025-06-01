'use strict';

var forumScraper = require('../../common/forum_scraper'),
  scrapers = require('../scrapers');

module.exports = forumScraper(scrapers, 'binary');

