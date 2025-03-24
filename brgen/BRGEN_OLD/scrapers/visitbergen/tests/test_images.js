'use strict';
var assert = require('assert');

var read = require('./utils').read,
  images = require('../scrapers/images');

tests();

function tests() {
  kunstlab();
  trolldom();
/*  singleImage();
  multipleImages();
  multipleImages2();
*/
}

function kunstlab() {
  read('kunstlab', function(data) {
    var result = images(data);

    assert.deepEqual(result, [
      'https://dur5nigvdd77h.cloudfront.net/imageresizer/?image=%2Fdmsimgs%2F90B60E8AC198DA9CF8CA42B24BD00669D53C10E7%2Ejpg&action=ProductMain',
      'https://dur5nigvdd77h.cloudfront.net/imageresizer/?image=%2Fdmsimgs%2F1CDF0AC2121A7A1FCAC9AE9DFFF344C273817A92%2Ejpg&action=ProductMain',
      'https://dur5nigvdd77h.cloudfront.net/imageresizer/?image=%2Fdmsimgs%2F63574B6525D188F38A17863DCBFCF168FE1B0EB6%2Ejpg&action=ProductMain'
    ]);
  });
}

function trolldom() {
  read('trolldom', function(data) {
    var result = images(data);

    assert.deepEqual(result, [
      'https://dur5nigvdd77h.cloudfront.net/imageresizer/?image=%2Fdmsimgs%2F00EBCEAFDFD87E11CDABE8C53CE838B9C8CA7F94%2Ejpg&action=ProductDetailEnhanced',
    ]);
  });
}

/*
function singleImage() {
  read('single_image', function(data) {
    var result = images(data);

    assert.deepEqual(result, [
      'http://media.tellus.no/images/?d=1&p=24048&t=1&.jpg'
    ]);
  });
}

function multipleImages() {
  read('multiple_images', function(data) {
    var result = images(data);

    assert.deepEqual(result, [
      'http://media.tellus.no/images/?d=1&p=4772&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=7240&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=4747&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=4749&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=4750&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=4751&t=1&.jpg'
    ]);
  });
}

function multipleImages2() {
  read('multiple_images2', function(data) {
    var result = images(data);

    assert.deepEqual(result, [
      'http://media.tellus.no/images/?d=1&p=7922&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=7923&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=7924&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=7925&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=7926&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=7927&t=1&.jpg',
      'http://media.tellus.no/images/?d=1&p=7928&t=1&.jpg'
    ]);
  })
}
*/
