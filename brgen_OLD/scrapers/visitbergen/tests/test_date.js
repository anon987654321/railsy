'use strict';

var assert = require('assert');

var read = require('./utils').read,
  date = require('../scrapers/date');

tests();

function tests() {
  startDate();
  endDate();
  startDate2();
  endDate2();
  lunchConcert();
}

function startDate() {
  read('text', function(data) {
    var result = date.start(data);

    assertDate(result, 'Nov 22, 2013');
  });
}

function endDate() {
  read('text', function(data) {
    var result = date.end(data);

    assertDate(result, 'Nov 23, 2013');
  });
}

function startDate2() {
  read('date', function(data) {
    var result = date.start(data);

    assertDate(result, 'Nov 29, 2013');
  });
}

function endDate2() {
  read('date', function(data) {
    var result = date.end(data);

    assertDate(result, 'Nov 30, 2013');
  });
}

function lunchConcert() {
  read('lunchconcert', function(data) {
    var start = date.start(data);
    var end = date.end(data);

    assertDate(start, 'Jun 1, 2014');
    assertDate(end, 'Sep 30, 2014');
  });
}

function assertDate(a, b) {
  assert.equal(a, new Date(b).toUTCString());
}

