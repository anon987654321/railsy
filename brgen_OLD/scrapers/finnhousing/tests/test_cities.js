'use strict';

var assert = require('assert');

var read = require('./utils').read,
  cities = require('../scrapers/cities');

tests();

function tests() {
  testCities();
}

function testCities() {
  read('catalog', function(data) {
    cities(data, function(err, items) {
      if(err) {
        return console.error(err);
      }

      assert.equal(Object.keys(items).length, 348);
      assert.equal(items['Bergen'], '1.20013.20220');
    });
  });
}
