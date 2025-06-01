var assert = require('assert');

var read = require('./utils').read,
  getMinReplies = require('../scrapers/get_min_replies');

tests();

function tests() {
  testGetMinReplies();
}

function testGetMinReplies() {
  read('topics', function(data) {
    getMinReplies(data, 70, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(d, [
        'http://forum.kvinneguiden.no/topic/1015805-jeg-var-den-andre-kvinnen-nå-stemor/',
        'http://forum.kvinneguiden.no/topic/1016085-burde-jeg-anmelde-dette-til-bv/',
        'http://forum.kvinneguiden.no/topic/1015645-jeg-må-knuse-mine-barns-hjerter/'
      ]);
    });
  });
}

