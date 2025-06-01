var assert = require('assert');

var read = require('./utils').read,
  catalog = require('../scrapers/catalog');

tests();

function tests() {
  testCatalog();
}

function testCatalog() {
  read('catalog', function(data) {
    catalog(data, function(err, items) {
      if(err) {
        return console.error(err);
      }

      assert.equal(items.length, 30);
      assert.equal(items[0], 'http://www.finn.no/finn/torget/annonse?finnkode=45401800');
      assert.equal(items[1], 'http://www.finn.no/finn/torget/annonse?finnkode=46334395');
    });
  });
}

