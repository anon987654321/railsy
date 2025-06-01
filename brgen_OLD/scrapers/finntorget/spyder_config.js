module.exports = {
  site: 'FINN Torget',

  initializer: require('../common/init'),
  indexer: require('./lib/indexer'),
  scraper: require('./lib/scraper'),

  onResult: require('../common/result'),

  // `Antikviteter og kunst`

  category: 76,
  county: 'Hordaland',
  city: 'Bergen',
  pages: 1
};

