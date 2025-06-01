'use strict';

var assert = require('assert');

var read = require('./utils').read,
  getMinReplies = require('../scrapers/get_min_replies');

tests();

function tests() {
  testGetMinReplies();
}

function testGetMinReplies() {
  read('topics', function(data) {
    getMinReplies(data, 45, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(d, [
        'http://www.diskusjon.no/index.php?showtopic=257251',
        'http://www.diskusjon.no/index.php?showtopic=176409',
        'http://www.diskusjon.no/index.php?showtopic=1270313',
        'http://www.diskusjon.no/index.php?showtopic=1298700',
        'http://www.diskusjon.no/index.php?showtopic=1362241'
      ]);
    });
  });
}

