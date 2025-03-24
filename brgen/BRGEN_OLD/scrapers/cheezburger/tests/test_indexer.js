'use strict';

var assert = require('assert');

var index = require('../lib/indexer');

tests();

function tests() {
  // useless test most of the time so disabling
  //testSingle();
}

function testSingle() {
  index({
    category: 'icanhascheezburger'
  }, function(err, data) {
    if(err) {
      return console.error(err);
    }

    // just checking that some data is received (no 404 etc.)
    assert(data.length > 0);
  });
}
