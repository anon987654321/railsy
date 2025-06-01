'use strict';

var forumScraper = require('../../common/forum_scraper'),
  scrapers = require('../scrapers');

// http://goo.gl/w7z0RL

module.exports = forumScraper(scrapers, 'binary');

