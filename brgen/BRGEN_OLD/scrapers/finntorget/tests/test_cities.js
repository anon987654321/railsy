var assert = require('assert');

var read = require('./utils').read,
  cities = require('../scrapers/cities');

tests();

function tests() {
  testCities();
}

function testCities() {
  read('cities', function(data) {
    cities(data, function(err, items) {
      if(err) {
        return console.error(err);
      }

      assert.equal(Object.keys(items).length, 20);
      assert.equal(items['Bergen'], '?sort=5&ITEM_CONDITION=0&SEGMENT=0&SEARCHKEYNAV=SEARCH_ID_BAP_ALL&location=1/20013/20220&categories=76');
    });
  });
}

