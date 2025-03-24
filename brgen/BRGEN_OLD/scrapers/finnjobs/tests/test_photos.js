'use strict';

var assert = require('assert');

var read = require('./utils').read,
  photos = require('../scrapers/photos');

tests();

function tests() {
  testPhotos();
}

function testPhotos() {
  read('item', function(data) {
    photos(data, function(err, urls) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(urls, [
        'http://finncdn.no/mmo/2014/1/24/7/463/372/17_1303914080_mediumlarge.png'
      ]);
    });
  });
}

