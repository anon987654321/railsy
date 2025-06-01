'use strict';

var assert = require('assert'),
  moment = require('moment');

var read = require('./utils').read,
  posts = require('../scrapers/posts');

tests();

function tests() {
  testGetPosts();
  testLucid();
  testEmoticons();
  testToday();
  testYesterday();
}

function testGetPosts() {
  read('nextpage', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert.equal(d.date, '2014-04-01T03:41:00+00:00');
      assert.equal(d.subject, 'Aprilsnarr april 2014');
      assert.equal(d.posts.length, 20);
      assert.deepEqual(d.posts[13], {
        date: '2014-04-01T05:28:00+00:00',
        text: 'I så fall er det i samarbeid med [Skatteetaten](http://www.skatteetaten.no/no/Person/Selvangivelse/Praktisk-om-selvangivelsen/Nar-skal-selvangivelsen-leveres/)...',
        photos_attributes: ['http://i.imgur.com/mTkIm9y.png'],
        avatar: 'http://static3.freak.no/forum/customavatars/avatar12532_2.gif',
        scraped_post_id: '3105611',
        reply_to_scraped_post_id: '3105606'
      });
    });
  });
}

function testLucid() {
  read('lucid', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert(d.posts[0].text.indexOf('\nFasene i') !== -1);
    });
  });
}

function testEmoticons() {
  read('hvordan', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      assert(d.posts[3].text.indexOf(':smile:') >= 0);
    });
  });
}

function testToday() {
  read('today', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }

      var today = moment();

      today.hours(9).minutes(58).seconds(0);

      assert.equal(d.posts[0].date, today.utc().format());
    });
  });
}

function testYesterday() {
  read('yesterday', function(data) {
    posts(data, function(err, d) {
      if(err) {
        return console.error(err);
      }
      var today = moment(),
        yesterday = today.add(-1, 'days');

      yesterday.hours(23).minutes(57).seconds(0);

      assert.equal(d.posts[d.posts.length - 1].date, yesterday.utc().format());
    });
  });
}

