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

      assert.equal(items.length, 50);
      assert.equal(items[0], 'http://m.finn.no/realestate/newbuildings/ad.html?finnkode=65112613&location=1.20013.20220&location=0.20013&ref=fas');
      assert.equal(items[1], 'http://m.finn.no/realestate/newbuildings/ad.html?finnkode=56877192&location=1.20013.20220&location=0.20013&ref=fas');
    });
  });
}

