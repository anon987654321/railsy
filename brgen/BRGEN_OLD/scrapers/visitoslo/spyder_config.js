module.exports = {
  site: 'VisitOSLO',

  initializer: require('../common/init'),
  indexer: require('./lib/indexer'),
  scraper: require('./lib/scraper'),

  onResult: require('../common/result'),

  pages: 1,
  category: 'aktiviteter-og-attraksjoner',
  subcategory: 'aktiviteter'
};

