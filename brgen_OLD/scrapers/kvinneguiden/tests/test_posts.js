'use strict';

var assert = require('assert');

var read = require('./utils').read,
  posts = require('../scrapers/posts');

tests();

function tests() {
  testOvernatte();
  /*
  testGetPhotos();
  testGetPosts();
  testGetPosts2();
  testGetPostsWithU();
  testGetPostsWithExtraDiv();
  testEmoticon();
  testEdited();
  testWithParentDiv();
  testAnonymous();
  testEncoding();
  */
}

function testOvernatte() {
  read('overnatte', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.subject, 'Datter på 17 overnatte hos motsatt kjønn?');
      assert.equal(d.date, '2016-03-29T21:00:00+00:00');
      assert.equal(d.posts.length, 20);
      assert.equal(d.posts[0].date, '2016-03-29T21:00:00+00:00');
      assert.equal(d.posts[0].avatar, 'http://forum.kvinneguiden.no/uploads/monthly_2015_11/avatar.thumb.jpg.9dd708c649c6d56013bd50a0842a84cc.jpg');
      assert.equal(d.posts[0].text.indexOf('Lar dere datteren deres som er over 16, overnatte hos det motsatte kjønn?'), 0);
      assert.equal(d.posts[0].poster, 'AnonymBruker');
      assert.equal(d.posts[0].scraped_post_id, '17890249');
    });
  });
}

/*
function testGetPosts() {
  read('photos', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      var photos = d.posts[0].photos_attributes;
      var expectedPhotos = [
        'http://forum.kvinneguiden.no/uploads//monthly_10_2014/post-76466-0-57856000-1414138164.jpg',
        'http://forum.kvinneguiden.no/uploads//monthly_10_2014/post-76466-0-95099700-1414138164.jpg',
        'http://forum.kvinneguiden.no/uploads//monthly_10_2014/post-76466-0-19365800-1414138165.jpg',
      ];

      assert.deepEqual(photos, expectedPhotos);
    });
  });
}

function testGetPhotos() {
  read('topic', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.subject, 'Frustrert deltidspappa, heltidspappa og mann!');
      assert.equal(d.date, '2014-01-19T22:00:00+00:00');
      assert.equal(d.posts.length, 20);
      assert.deepEqual(d.posts[1], {
        date: '2014-01-20T14:33:22+00:00',
        avatar: 'http://forum.kvinneguiden.no/uploads//av-11780.jpg',
        poster: 'Gjest',
        text: '\n\n\nMeg',
        scraped_post_id: '13836381',
        reply_to_scraped_post_id: undefined,
        'photos_attributes': ['http://upload.wikimedia.org/wikipedia/en/4/4e/Shibe_Inu_Doge_meme.jpg']
      });
      assert.equal(d.posts[0].date, '2014-01-20T14:30:57+00:00');
      assert.equal(d.posts[0].avatar, undefined);
      assert.equal(d.posts[0].text.indexOf('Kvinneguiden? Hvorfor er jeg her?'), 0);
      assert.equal(d.posts[0].poster, 'Hverdagspappa');
      assert.equal(d.posts[0].scraped_post_id, '13836373');
      assert.equal(d.posts[2].reply_to_scraped_post_id, '13836381');
      assert.equal(d.posts[5].poster, 'f1a254616378fcb280905b05d7db4715');
    });
  });
}

function testGetPosts2() {
  read('topic2', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.subject, 'ekskjæreste og sosiale media');
      assert.equal(d.posts[0].text.indexOf('*Anonymous poster hash: *'), -1);
    });
  });
}

function testGetPostsWithU() {
  read('topic_with_u', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.posts[0].text.indexOf('<u>'), -1);
    });
  });
}

function testGetPostsWithExtraDiv() {
  read('topic_with_extra_div', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.posts[0].text.indexOf('<div>'), -1);
    });
  });
}

function testEmoticon() {
  read('topic', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert(d.posts[4].text.indexOf(':smile:') >= 0);
    });
  });
}

function testEdited() {
  read('edited', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.posts[5].text.indexOf('Dette innlegget har blitt redigert av **Story**: i går, 15:05'), -1);
    });
  });
}

function testWithParentDiv() {
  read('topic_with_parent_div', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.posts[0].text.indexOf('<div>'), -1);
    });
  });
}

function testAnonymous() {
  read('anonym_poster', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.posts[0].text.indexOf('Anonym poster'), -1);
    });
  });
}

function testEncoding() {
  read('encoding', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.subject, 'Lønnsforskjell mellom ingeniør og sykepleier');
    });
  });
}
*/
