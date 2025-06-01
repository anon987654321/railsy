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
    getMinReplies(data, 60, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(d, [
        'http://freak.no/forum/showthread.php?t=44213',
        'http://freak.no/forum/showthread.php?t=264379',
        'http://freak.no/forum/showthread.php?t=267037'
      ]);
    });
  });
}

