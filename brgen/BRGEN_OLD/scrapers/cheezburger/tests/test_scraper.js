'use strict';

var assert = require('assert');

var scrape = require('../lib/scraper');

var data = require('./data/demo.json');

tests();

function tests() {
  testScrape1(data[0]);
  testScrape2(data[1]);
  testScrape3(data[2]);
  testScrape4(data[3]);
}

function testScrape1(data) {
  scrape({
    photos: './photos'
  }, data, function(err, results) {
    if(err) {
      return console.error(err);
    }

    // each "page" should have just a single result
    assert.equal(results.length, 1);

    var result = results[0];

    assert.equal(result.subject, 'Quiz: What Do You Know About Black Cats?');
    assert.equal(result['posts_attributes'][0].sources[0].name, 'Cheezburger');
    assert.equal(result['posts_attributes'][0].sources[0].url, 'https://www.playbuzz.com/kristy14/what-do-you-know-about-black-cats');
  });
}

function testScrape2(data) {
  scrape({
    photos: './photos'
  }, data, function(err, results) {
    if(err) {
      return console.error(err);
    }

    var result = results[0];

    assert.equal(result.subject, 'I Am the Night! ...Keep Rubbing My Belly Though');
    assert.equal(result['posts_attributes'][0].sources[0].name, '@elfie_gimli');
    assert.equal(result['posts_attributes'][0].sources[0].url, 'https://instagram.com/elfie_gimli/');
  });
}

function testScrape3(data) {
  scrape({
    photos: './photos'
  }, data, function(err, results) {
    if(err) {
      return console.error(err);
    }

    var result = results[0];

    assert.equal(result.subject, 'Watching a Koala Chase Down a Woman is Either Hilarious or Terrifying');
    assert.equal(result['posts_attributes'][0].sources[0].name, 'Ebony Churchill');
    assert.equal(result['posts_attributes'][0].sources[0].url, 'https://www.facebook.com/ebony.churchill/videos/vb.1301100946/10204599048038423/?type=2&theater');
  });
}

function testScrape4(data) {
  scrape({
    photos: './photos'
  }, data, function(err, results) {
    if(err) {
      return console.error(err);
    }

    var result = results[0];

    assert.equal(result.subject, 'Elephants Visit This Lodge Around the Same Time Every Year');
    assert.equal(result['posts_attributes'][0].text, 'https://www.youtube.com/embed/z5EsHnI03zA');
    assert.equal(result['posts_attributes'][0].sources[0].name, 'The Bushcamp Company');
    assert.equal(result['posts_attributes'][0].sources[0].url, 'https://www.youtube.com/watch?t=228&v=z5EsHnI03zA');
  });
}
