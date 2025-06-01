'use strict';

var assert = require('assert');

var read = require('./utils').read,
  text = require('../scrapers/text');

tests();

function tests() {
  boat();
  inferno();
}

function boat() {
  read('boat', function(data) {
    text(data, function(err, result) {
      if(err) {
        return console.error(err);
      }

      assert.equal(result.split('\n').length, 32);
    });
  });
}

function inferno() {
  read('inferno', function(data) {
    text(data, function(err, result) {
      if(err) {
        return console.error(err);
      }

      assert.equal(result.split('\n').length, 6);
    });
  });
}

