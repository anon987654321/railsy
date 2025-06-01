'use strict';

var assert = require('assert');

var read = require('./utils').read,
  posts = require('../scrapers/posts'),
  request = require('request');

tests();

function tests() {
  testGetPosts();
  testGetSubject();
  testLinebreaks();
  testDoublelist();
  testYoutube();
  testGravatar();
  testEmoticon();
  testNoAvatar();
}

function testGetPosts() {
  read('topic', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.subject, 'Den store DIY-tråden [Update: 06/09-07]');
      assert.equal(d.date, '2007-07-29T21:00:00+00:00');
      assert.equal(d.posts.length, 20);
      assert.equal(d.posts[4]['photos_attributes'][0], 'http://www.diskusjon.no/uploads/post-112734-1186180307.jpg');
      assert.equal(d.posts[0].avatar, 'http://www.diskusjon.no/uploads/av-112734.jpg');
      assert.equal(d.posts[0].scraped_post_id, '9173584');
      assert.equal(d.posts[0].date, '2007-07-30T15:31:40+00:00');
      assert.equal(d.posts[19].reply_to_scraped_post_id, '13402622');
      assert.equal(d.posts[19].date, '2009-03-24T21:27:16+00:00');
    });
  });
}

function testGetSubject() {
  request.get('http://www.diskusjon.no/index.php?s=39cef897a87ff6332936c0b7aae0f8aa&showtopic=1573740', {
    encoding: 'binary'
  },function(err, res, data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.subject, '[Løst] Fra svart hår til mørkeblondt');
    });
  });
}

function testLinebreaks() {
  read('linebreaks', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.subject, '[Løst] Fra svart hår til mørkeblondt');
      assert.equal(d.posts.length, 1);
      assert.equal(d.posts[0].text.split('\n\n').length, 7);
      assert.equal(d.posts[0]['photos_attributes'].length, 0);
    });
  });
}

function testDoublelist() {
  read('doublelist', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert(d.posts[0].text.indexOf('</span>') === -1);
      assert(d.posts[0].text.indexOf('Dette innlegget har') === -1);
    });
  });
}

function testYoutube() {
  read('topic', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert(d.posts[1].text.indexOf('<iframe') === -1);
      assert(d.posts[1].text.indexOf('http://www.youtube.com/embed/ZNHGLwhqsIY') !== -1);
    });
  });
}

function testGravatar() {
  read('gravatar', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      // TODO: Find an example with a valid non-default gravatar

      assert.equal(d.posts[12].avatar, undefined);
    });
  });
}

function testEmoticon() {
  read('topic', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert(d.posts[0].text.indexOf(':smile:') >= 0);
    });
  });
}

function testNoAvatar() {
  read('topic', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.posts[1].avatar, undefined);
    });
  });
}

