module.exports = {
  site: 'FINN Housing',

  initializer: require('../common/init'),
  indexer: require('./lib/indexer'),
  scraper: require('./lib/scraper'),

  onResult: require('../common/result'),

  category: 'realestate/homes',
  county: 'Hordaland',
  city: 'Bergen',
  pages: 1
};

