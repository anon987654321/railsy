'use strict';
var assert = require('assert');

var read = require('./utils').read,
  photos = require('../scrapers/photos');

tests();

function tests() {
  testPhotos();
  testUbrukt();
}

function testPhotos() {
  read('item', function(data) {
    photos(data, function(err, urls) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(urls, [
        'http://finncdn.no/mmo/2013/11/vertical-5/25/0/454/018/00_285630610.jpg',
        'http://finncdn.no/mmo/2013/11/vertical-5/25/0/454/018/00_412390873.jpg',
        'http://finncdn.no/mmo/2013/11/vertical-5/25/0/454/018/00_456997929.jpg',
        'http://finncdn.no/mmo/2013/11/vertical-5/25/0/454/018/00_1034053966.jpg'
      ]);
    });
  });
}

function testUbrukt() {
  read('ubrukt', function(data) {
    photos(data, function(err, urls) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(urls, [
        'http://finncdn.no/mmo/2014/9/vertical-5/25/0/519/915/60_2105582754.jpg',
        'http://finncdn.no/mmo/2014/9/vertical-5/25/0/519/915/60_2031171221.jpg',
        'http://finncdn.no/mmo/2014/9/vertical-5/25/0/519/915/60_1138262229.jpg'
      ]);
    });
  });
}

