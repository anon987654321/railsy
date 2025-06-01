'use strict';

var assert = require('assert');

var read = require('./utils').read,
  details = require('../scrapers/details');

tests();

function tests() {
  testNattJazz();
}

function testNattJazz() {
  read('nattjazz', function(data) {
    var result = details(data);

    // XXX: calculated based on location using js
    //assert.equal(result['km_from_airport'], '12');
    //assert.equal(result['km_from_city_center'], '0');

    assert.equal(result['email'], 'http://www.visitbergen.com/hva-skjer/nattjazz-p880173/email');
    assert.equal(result['website'], 'http://www.nattjazz.no');
    assert.equal(result['phone'], '55 30 72 50');

    // XXX: passed other way. see scraper.js
    //assert.equal(result['source_link'], 'http://www.visitbergen.com/hva-skjer/nattjazz-p880173');
  });
}
