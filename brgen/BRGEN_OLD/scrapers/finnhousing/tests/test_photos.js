var assert = require('assert');

var read = require('./utils').read,
  photos = require('../scrapers/photos');

tests();

function tests() {
  testPhotos();
}

function testPhotos() {
  read('stjern', function(data) {
    photos(data, function(err, urls) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(urls, [
        'https://finncdn.no/dynamic/1600w/2016/1/vertical-2/07/0/580/411/20_1904125250.jpg',
        'https://finncdn.no/dynamic/320w/2016/1/vertical-2/07/0/580/411/20_1904125250.jpg',
        'https://finncdn.no/dynamic/640w/2016/1/vertical-2/07/0/580/411/20_1904125250.jpg',
        'https://finncdn.no/dynamic/960w/2016/1/vertical-2/07/0/580/411/20_1904125250.jpg'
      ]);
    });
  });
}
