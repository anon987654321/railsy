'use strict';

var assert = require('assert');

var read = require('./utils').read,
  getNextPage = require('../scrapers/get_next_page');

tests();

function tests() {
  testGetNextPage();
  testHvordan();
}

function testGetNextPage() {
  read('nextpage', function(data) {
    getNextPage(data, function(err, url) {
      if(err) {
        return console.error(err);
      }

      assert.equal(url, 'http://freak.no/forum/showthread.php?t=267199&page=2');
    });
  });
}

function testHvordan() {
  read('hvordan', function(data) {
    getNextPage(data, function(err, url) {
      if(err) {
        return console.error(err);
      }

      assert.equal(url, 'http://freak.no/forum/showthread.php?t=44213&page=11');
    });
  });
}

