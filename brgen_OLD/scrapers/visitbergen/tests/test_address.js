'use strict';

var assert = require('assert');

var read = require('./utils').read,
  address = require('../scrapers/address');

tests();

function tests() {
  testNattJazz();
  /*
  testProcessAddress();
  testProcessAddressWithMarkup();
  testProcessNoFax();
  testProcessMinimalAddress();
  testProcessAddressWithGif();
  testProcessHalvtimen();
  */
}

function testNattJazz() {
  read('nattjazz', function(data) {
    var result = address(data);

    assert.equal(result.address, 'Georgernes Verft');
    assert.equal(result.zip, '5011 Bergen');
  });
}

/*
function testProcessAddress() {
  read('text', function(data) {
    var result = address(data);

    assert.equal(result.place, 'Hulen');
    assert.equal(result.address, 'Olaf Ryes vei 47');
    assert.equal(result.po, '5006 Bergen');
    assert.equal(result.phone, '55 33 38 30');
    assert.equal(result.email, 'hulen@hulen.no');
    assert.equal(result.url, 'http://www.hulen.no');
  });
}

function testProcessAddressWithMarkup() {
  read('address', function(data) {
    var result = address(data);

    assert.equal(result.place, 'Logen Teater');
    assert.equal(result.address, '&#xD8;vre Ole Bulls Plass 6');
    assert.equal(result.po, '5012 Bergen');
    assert.equal(result.phone, '55 23 20 15');
    assert.equal(result.email, 'post@logen-teater.no');
    assert.equal(result.url, 'http://www.logen-teater.no');
  });
}

function testProcessNoFax() {
  read('strong_text', function(data) {
    assert.deepEqual(address(data), {
      place: 'Chagall',
      address: 'Vaskerelven 1',
      po: '5011 Bergen',
      phone: '938 92 273',
      email: 'finn.totland@helse-bergen.no',
      url: 'http://www.BK-musikk.no'
    });
  });
}

function testProcessMinimalAddress() {
  read('minimal_address', function(data) {
    assert.deepEqual(address(data), {
      place: 'Skrivergaarden, Augustin Hotel',
      address: 'C. Sundtsgate 22-24',
      po: '5004 Bergen',
      phone: '',
      email: '',
      url: 'http://www.folkemusikk.no/columbiegg'
    });
  });
}

function testProcessAddressWithGif() {
  read('address_with_gif', function(data) {
    assert.deepEqual(address(data), {
      place: 'VilVite',
      address: 'Thorm&#xF8;hlensgate 51',
      po: '',
      phone: '55 59 45 00',
      email: 'post@vilvite.no',
      url: 'http://www.vilvite.no'
    });
  });
}

function testProcessHalvtimen() {
  read('halvtimen', function(data) {
    assert.deepEqual(address(data), {
      place: 'Det Akademiske Kvarter',
      address: 'Olav Kyrres gate 49',
      po: '5015 Bergen',
      phone: '406 26 601',
      email: 'booking@kvarteret.no',
      url: 'http://www.kvarteret.no'
    });
  });
}
*/
