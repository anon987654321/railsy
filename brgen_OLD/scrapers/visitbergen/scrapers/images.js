'use strict';
var cheerio = require('cheerio');

function scrape(data) {
  var $ = cheerio.load(data);
  var imgSwapCtrl = $('#imgSwapCtrl a').map(function(i, el) {
    return $(el).attr('href');
  }).get().filter(id);

  if(imgSwapCtrl.length) {
    return imgSwapCtrl;
  }

  return $('.imgWrapper img').map(function(i, el) {
    return $(el).attr('src');
  }).get().filter(id);
}

module.exports = scrape;

function id(a) { return a; }

