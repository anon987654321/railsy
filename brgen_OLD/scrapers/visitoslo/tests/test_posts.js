'use strict';

var assert = require('assert');

var read = require('./utils').read,
  posts = require('../scrapers/posts');

tests();

function tests() {
  testGetPosts();
}

function testGetPosts() {
  read('catalog', function(data) {
    var result = posts(data);

    assert(result.length === 15);
  });
}

