'use strict';

var assert = require('assert');

var read = require('./utils').read,
  scrape = require('../lib/indexer').scrape;

tests();

function tests() {
  testIndex();
}

function testIndex() {
  read('index', function(data) {
    var result = scrape(data);

    // TODO: include visitbergen prefix here?
    assert.equal(
      result[0],
      '/hva-skjer/guiding-i-tropisk-avdeling-p1504353'
    );
    assert.equal(
      result[1],
      '/hva-skjer/fiskeforing-i-rotunden-p1504333'
    );
    assert.equal(result.length, 20);
  });
}

