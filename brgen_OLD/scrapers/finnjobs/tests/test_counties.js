'use strict';

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

      assert.equal(Object.keys(items).length, 20);
      assert.equal(items['Akershus'], '?sort=0&location=1/20001/20003');
      assert.equal(items['Aust-Agder'], '?sort=0&location=1/20001/20010');
    });
  });
}

