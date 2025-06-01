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
        'http://www.diskusjon.no/index.php?showtopic=541774',
        'http://www.diskusjon.no/index.php?showtopic=257251',
        'http://www.diskusjon.no/index.php?showtopic=176409',
        'http://www.diskusjon.no/index.php?showtopic=1270313',
        'http://www.diskusjon.no/index.php?showtopic=1298700',
        'http://www.diskusjon.no/index.php?showtopic=1362241',
        'http://www.diskusjon.no/index.php?showtopic=1417731'
      ]);
    });
  });
}

