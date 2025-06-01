module.exports = {
  site: 'visitBergen',

  initializer: require('../common/init'),
  indexer: require('./lib/indexer'),
  scraper: require('./lib/scraper'),

  onResult: require('../common/result'),

  date: new Date(),
  category: 'hva-skjer',
  subcategory: '1-1222'
};

