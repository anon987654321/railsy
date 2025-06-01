'use strict';

var assert = require('assert');

var read = require('./utils').read,
  text = require('../scrapers/text');

tests();

function tests() {
  testNattJazz();
  /*
  testText();
  testText2();
  testText3();
  testText4();
  testText5();
  testStrongText();
  testStrong();
  testSkipContacts();
  */
}

function testNattJazz() {
  read('nattjazz', function(data) {
    text(data, function(err, result) {
      if(err) {
        return console.error(err);
      }

      assert.equal(result.split('\n\n').length, 6);
    });
  });
}

/*
function testText() {
  read('text', function(data) {
    var result = text(data);

    assert.equal(result.split('\n\n').length, 2);
  });
}

function testText2() {
  read('text2', function(data) {
    var result = text(data);

    assert.equal(result.split('\n\n').length, 2);
    assert.equal(result.split('\n').length, 7);
  });
}

function testText3() {
  read('text3', function(data) {
    var result = text(data);

    assert.equal(result.split('\n\n').length, 1);
  });
}

function testText4() {
  read('text4', function(data) {
    var result = text(data);

    assert.equal(result.split('\n\n').length, 1);
  });
}

function testText5() {
  read('text5', function(data) {
    var result = text(data);

    assert.equal(result.split('\n\n').length, 11);
  });
}

function testStrongText() {
  read('strong_text', function(data) {
    var result = text(data);

    assert.equal(result.split('\n\n').length, 9);
    assert.equal(result.split('\n').length, 27);
  });
}

function testStrong() {
  read('strong', function(data) {
    var result = text(data);

    // Eliminate empty strongs

    assert.equal(result.indexOf('********'), -1);
  });
}

function testSkipContacts() {
  read('skip_contacts', function(data) {
    var result = text(data);

    assert.equal(result.split('\n\n').length, 1);
  });
}
*/
