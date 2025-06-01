var assert = require('assert');

var read = require('./utils').read,
  getNextPage = require('../scrapers/get_next_page');

tests();

function tests() {
  testGetnextpage();
  testNonextpage();
}

function testGetnextpage() {
  read('overnatte', function(data) {
    getNextPage(data, function(err, url) {
      if(err) {
        return console.error(err);
      }

      assert.equal(url, 'http://forum.kvinneguiden.no/topic/1015438-datter-på-17-overnatte-hos-motsatt-kjønn/?page=2');
    });
  });
}

function testNonextpage() {
  read('nonext', function(data) {
    getNextPage(data, function(err, url) {
      assert.equal(err.message, 'URL not found');
    });
  });
}
