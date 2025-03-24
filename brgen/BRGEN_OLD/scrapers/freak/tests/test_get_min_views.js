'use strict';

var assert = require('assert');

var read = require('./utils').read,
  getMinViews = require('../scrapers/get_min_views');

tests();

function tests() {
  testGetMinViews();
}

function testGetMinViews() {
  read('topics', function(data) {
    getMinViews(data, 10000, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(d, [
        'http://freak.no/forum/showthread.php?t=44213',
        'http://freak.no/forum/showthread.php?t=264379',
        'http://freak.no/forum/showthread.php?t=103004'
      ]);
    });
  });
}

