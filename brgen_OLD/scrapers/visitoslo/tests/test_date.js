'use strict';

var assert = require('assert');

var read = require('./utils').read,
  date = require('../scrapers/date');

tests();

function tests() {
  boat();
  inferno();
}

function boat() {
  read('boat', function(data) {
    var startResult = date.start(data),
      endResult = date.start(data);

    assert(!startResult);
    assert(!endResult);
  });
}

function inferno() {
  read('inferno', function(data) {
    var startResult = date.start(data),
      endResult = date.end(data),
      expectedStart = new Date(2014, 3, 16).toUTCString(),
      expectedEnd = new Date(2014, 3, 19).toUTCString();

    assert.equal(startResult, expectedStart);
    assert.equal(endResult, expectedEnd);
  });
}

