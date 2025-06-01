'use strict';

var assert = require('assert');

var read = require('./utils').read,
  images = require('../scrapers/images');

tests();

function tests() {
  boat();
  inferno();
}

function boat() {
  read('boat', function(data) {
    var result = images(data);

    assert.deepEqual(result, [
      'http://media.tellus.no/images/?d=23&p=6680&t=1',
      'http://media.tellus.no/images/?d=23&p=6689&t=1',
      'http://media.tellus.no/images/?d=23&p=6682&t=1',
      'http://media.tellus.no/images/?d=23&p=6687&t=1'
    ]);
  });
}

function inferno() {
  read('inferno', function(data) {
    var result = images(data);

    assert.deepEqual(result, [
      'http://media.tellus.no/images/?d=23&p=10919&t=1',
      'http://media.tellus.no/images/?d=23&p=9915&t=1',
      'http://media.tellus.no/images/?d=23&p=9916&t=1',
      'http://media.tellus.no/images/?d=23&p=9917&t=1',
      'http://media.tellus.no/images/?d=23&p=9914&t=1'
    ]);
  });
}

