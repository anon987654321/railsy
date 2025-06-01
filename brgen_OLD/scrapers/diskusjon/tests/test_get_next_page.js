'use strict';

var assert = require('assert');

var read = require('./utils').read,
  getNextPage = require('../scrapers/get_next_page');

tests();

function tests() {
  testGetNextPage();
}

function testGetNextPage() {
  read('nextpage', function(data) {
    getNextPage(data, function(err, url) {
      if(err) {
        return console.error(err);
      }

      assert.equal(url, 'http://www.diskusjon.no/index.php?showtopic=541774&page=2');
    });
  });
}

