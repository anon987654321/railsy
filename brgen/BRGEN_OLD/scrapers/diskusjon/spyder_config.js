module.exports = {
  site: 'Diskusjon',

  initializer: require('../common/init'),
  indexer: require('./lib/indexer'),
  scraper: require('./lib/scraper'),

  onResult: require('../common/result'),

  pages: 1,
  'min_views': 100,
  'min_replies': 50
};

