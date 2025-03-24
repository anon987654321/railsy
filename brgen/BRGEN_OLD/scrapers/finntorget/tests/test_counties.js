var assert = require('assert');

var read = require('./utils').read,
  counties = require('../scrapers/counties');

tests();

function tests() {
  testCounties();
}

function testCounties() {
  read('catalog', function(data) {
    counties(data, function(err, items) {
      if(err) {
        return console.error(err);
      }

      assert.equal(Object.keys(items).length, 19);
      assert.equal(items['Akershus'], '?sort=5&SEARCHKEYNAV=SEARCH_ID_BAP_ALL&location=0/20003&categories=76');
      assert.equal(items['Aust-Agder'], '?sort=5&SEARCHKEYNAV=SEARCH_ID_BAP_ALL&location=0/20010&categories=76');
    });
  });
}

