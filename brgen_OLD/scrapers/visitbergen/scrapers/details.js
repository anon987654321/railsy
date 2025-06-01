'use strict';

var cheerio = require('cheerio'),
  extract = require('annostring').extract;

module.exports = function(data) {
  var prefix = 'http://www.visitbergen.com';
  var $ = cheerio.load(data),
    //$distance = $('.distanceWrapper'),
    $contact = $('.ContactWrapper'),
    $phone = $('.PhoneWrapper');

  return {
    // XXX: calculated based on location using js
    //'km_from_airport': $distance.find('.distanceCalculationFrom').text(),
    //'km_from_city_center': '0',

    'email': prefix + $contact.find('.email a').attr('href'),
    'website': decodeURIComponent($contact.find('.website a').attr('href').split('?web=')[1]),
    'phone': $phone.find('span').text()
  };
}
