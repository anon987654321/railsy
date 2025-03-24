module.exports = {
  site: 'Cheezburger',

  initializer: require('../common/init'),
  indexer: require('./lib/indexer'),
  scraper: require('./lib/scraper'),

  onResult: require('../common/result'),

  pages: 1,
  'min_likes': 100,
  'max_dislikes': 100
};

