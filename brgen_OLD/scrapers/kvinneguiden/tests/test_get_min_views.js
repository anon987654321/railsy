var assert = require('assert');

var read = require('./utils').read,
  getMinViews = require('../scrapers/get_min_views');

tests();

function tests() {
  testGetMinViews();
}

function testGetMinViews() {
  read('topics', function(data) {
    getMinViews(data, 3000, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(d, [
        'http://forum.kvinneguiden.no/topic/1015805-jeg-var-den-andre-kvinnen-nå-stemor/',
        'http://forum.kvinneguiden.no/topic/1015645-jeg-må-knuse-mine-barns-hjerter/'
      ]);
    });
  });
}

