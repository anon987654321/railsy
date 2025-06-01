'use strict';

var assert = require('assert');

var read = require('./utils').read,
  address = require('../scrapers/address');

tests();

function tests() {
  boat();
  inferno();
}

function boat() {
  read('boat', function(data) {
    var result = address(data);

    assert.equal(result.address, 'Rådhusbrygge 3');
    assert.equal(result.po, '0116 Oslo');
    assert.equal(result.phone, '23 35 68 90');
    assert.equal(result.email, 'sales@boatsightseeing.com');
    assert.equal(result.url, 'http://www.boatsightseeing.com');
  });
}

function inferno() {
  read('inferno', function(data) {
    var result = address(data);

    assert.equal(result.phone, '22 20 32 32');
    assert.equal(result.email, 'post@rockefeller.no');
    assert.equal(result.url, 'http://www.infernofestival.net');
  });
}

