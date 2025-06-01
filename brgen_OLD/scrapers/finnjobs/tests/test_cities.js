'use strict';

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

      assert.equal(Object.keys(items).length, 17);
      assert.equal(items['Bergen'], '?sort=0&location=2%2F20001%2F20013%2F20220');
    });
  });
}

