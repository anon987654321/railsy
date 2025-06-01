'use strict';

var assert = require('assert');

var read = require('./utils').read,
  item = require('../scrapers/item'),
  format = require('../lib/scraper').formatContent;

tests();

function tests() {
  testDeltid();
  testTelenor();
}

function testDeltid() {
  read('deltid', function(data) {
    item(data, function(err, data) {
      if(err) {
        return console.error(err);
      }

      var result = format('', data);

      assert.equal(result.indexOf('undefined'), -1);
    });
  });
}

function testTelenor() {
  read('telenor', function(data) {
    item(data, function(err, data) {
      if(err) {
        return console.error(err);
      }

      var result = format('', data);

      assert.equal(result.indexOf('undefined'), -1);
    });
  });
}
