'use strict';

var assert = require('assert');

var read = require('./utils').read,
  subject = require('../scrapers/subject');

tests();

function tests() {
  boat();
  inferno();
}

function boat() {
  read('boat', function(data) {
    var result = subject(data);

    assert.equal(result, 'Båtservice Sightseeing');
  });
}

function inferno() {
  read('inferno', function(data) {
    var result = subject(data);

    assert.equal(result, 'Inferno Metal Festival');
  });
}

