module.exports = {
  site: 'FINN Jobs',

  initializer: require('../common/init'),
  indexer: require('./lib/indexer'),
  scraper: require('./lib/scraper'),

  onResult: require('../common/result'),

  // Choose between `fulltime` and `parttime`

  category: 'fulltime',
  county: 'Hordaland',
  city: 'Bergen',
  pages: 1
};

