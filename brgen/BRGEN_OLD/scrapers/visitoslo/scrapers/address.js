'use strict';

var cheerio = require('cheerio');

module.exports = function(data) {
  var $ = cheerio.load(data),
    $contact = $('.pib-contact-info-list'),
    url = trimParentText($contact.find('.icon-home-gray'));

  return {
    address: trimParentText($contact.find('.icon-place-gray')),
    po: trimParentNextText($contact.find('.icon-place-gray')),
    phone: trimParentText($contact.find('.icon-tel')),
    email: trimParentText($contact.find('.icon-contact')),
    url: url && 'http://' + url
  };
};

function trimParentText($e) {
    return $e.first().parent().text().trim();
}

function trimParentNextText($e) {
    return $e.first().parent().next().text().trim();
}

function id(a) { return a; }

