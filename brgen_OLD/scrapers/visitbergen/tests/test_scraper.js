'use strict';

var assert = require('assert');

var read = require('./utils').read,
  scrape = require('../lib/scraper').scrape;

tests();

function tests() {
  //testHalvtimen();
  //testCostello();
}

/*
function testHalvtimen() {
  read('halvtimen', function(data) {
    var result = scrape('Visit Bergen', 'demo url', [], data);

    assert.equal(result.subject, 'Halvtimen');
    assert(result['posts_attributes'][0].text.indexOf('20 års aldersgrense!') >= 0);
  });
}

function testCostello() {
  read('costello', function(data) {
    var result = scrape('Visit Bergen', 'demo url', [], data);

    assert.equal(result.subject, 'Elvis Costello Solo');
  });
}
*/
