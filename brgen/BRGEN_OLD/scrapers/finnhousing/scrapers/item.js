'use strict';

var cheerio = require('cheerio');


module.exports = function(data, cb) {
  var $ = cheerio.load(data);

  cb(null, {
    title: $('h1').text(),
    address: scrapeAddress($),
    details: scrapeDetails($),
    contacts: scrapeContacts($)
  });
};

function scrapeAddress($) {
  var text = $('.unit.r-size2of3 .bd h2').first().text();
  var parts = text.split(',');

  if(parts.length < 2) {
    text = $('.unit.r-size2of3 .bd p').first().text();
    parts = text.split(',');
  }

  if(parts.length > 1) {
    return {
      address: parts[0].trim(),
      zip: parts[1].trim(),
    };
  }

  return {};
}

function scrapeDetails($) {
  var $e = $('.unit.r-size2of3 .bd').first();

  return {
    price1: $e.find('.h1.mtn.r-margin').eq(0).text(),
    price2: $e.find('.h1.mtn.r-margin').eq(1).text(),
    size: $e.find('dd').eq(0).text().trim(),
    type: $e.find('dd').eq(2).text().trim(),
    bedrooms: $e.find('dd').eq(1).text().trim(),
    tenure: $e.find('dd').eq(3).text().trim()
  };
}

function scrapeContacts($) {
  var $e = $('.unit.r-size1of3 .extended-profile .contact');

  if($e.length) {
    return $e.map(function(i, e) {
      var $e = $(e);

      return {
        name: $e.find('.name').text(),
        role: $e.find('.title').text(),
        phone: $e.find('a[data-controller="trackCallContact"]').attr('href').split(':')[1],
        'contact_link': 'http://m.finn.no' + $e.find('a[data-controller="trackSendMessage"]').attr('href')
      };
    }).get();
  }

  $e = $('.unit.r-size1of3 .bd');

  return $e.find('dl:contains(\'egler\')').map(function(i, e) {
    var $e = $(e);

    return {
      name: $e.find('dd').text().trim(),
      role: '',
      phone: $e.parent().find('a[data-controller="trackSendSMS"]').attr('href').split(':')[1],
      'contact_link': 'http://m.finn.no' + $e.next().next().find('.mbs a').eq(1).attr('href')
    };
  }).get();
}
