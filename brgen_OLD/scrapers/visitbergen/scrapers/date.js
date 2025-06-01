'use strict';

var cheerio = require('cheerio'),
  moment = require('moment');

function start(data) {
  var $ = cheerio.load(data),
    t = $('.datecol').last().text().split('-')[0];

  if(!t) {
    return;
  }

  return moment(t, 'DD-MM-YYYY').toDate().toUTCString();
}
exports.start = start;

function end(data) {
  var $ = cheerio.load(data),
    t = $('.datecol').last().text().split('-')[1];

  if(!t) {
    return;
  }

  return moment(t, 'DD-MM-YYYY').toDate().toUTCString();
}
exports.end = end;

