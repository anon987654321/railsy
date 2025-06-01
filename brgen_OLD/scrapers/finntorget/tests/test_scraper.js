'use strict';

var assert = require('assert');

var read = require('./utils').read,
  getItem = require('../lib/scraper').getItem;

tests();

function tests() {
  testUbrukt();
}

function testUbrukt() {
  read('ubrukt', function(data) {
    getItem(function(url, fn) {
      fn(null, data);
    }, '', function(err, res) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(res.photos, [
        'http://finncdn.no/mmo/2014/9/vertical-5/25/0/519/915/60_2105582754.jpg',
        'http://finncdn.no/mmo/2014/9/vertical-5/25/0/519/915/60_2031171221.jpg',
        'http://finncdn.no/mmo/2014/9/vertical-5/25/0/519/915/60_1138262229.jpg'
      ]);
    });
  });
}

