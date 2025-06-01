'use strict';

var assert = require('assert');

var read = require('./utils').read,
  occupation = require('../scrapers/occupation');

tests();

function tests() {
  testOccupation();
}

function testOccupation() {
  read('occupation', function(data) {
    occupation(data, function(err, items) {
      if(err) {
        return console.error(err);
      }

      // Includes hidden occupations as well

      assert.equal(Object.keys(items).length, 68);
      assert.equal(items['Butikkansatt'], '?sort=0&occupation=0/6');
      assert.equal(items['Helsepersonell'], '?sort=0&occupation=0/16');
    });
  });
}

