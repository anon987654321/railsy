'use strict';

var cheerio = require('cheerio');

function start(data) {
  var $ = cheerio.load(data),
    t = $('.pib-date-area').text();

  if(!t) {
    return;
  }

  t =  t.trim().split('-')[0].split('.');

  return new Date(t[2], t[1] - 1, t[0]).toUTCString();
}
exports.start = start;

function end(data) {
  var $ = cheerio.load(data),
    t = $('.pib-date-area').text();

  if(!t) {
    return;
  }

  t =  t.trim().split('-')[1].split('.');

  return new Date(t[2], t[1] - 1, t[0]).toUTCString();
}
exports.end = end;

