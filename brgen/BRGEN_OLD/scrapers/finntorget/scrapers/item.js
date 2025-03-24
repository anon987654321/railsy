'use strict';

var async = require('async'),
  cheerio = require('cheerio'),
  getText = require('../../common/get_text'),
  replaceWithContent = getText.replaceWithContent;

module.exports = function(data, cb) {
  var $ = cheerio.load(data);

  $('.object-description h2').remove();

  replaceWithContent($, $('.object-description'), '.mtm', function($e) {
    return '<p>' + $e.text() + '</p>';
  });

  var title = $('h1[data-automation-id="heading"]').text(),
    price = $('#objectPriceInfo .h2').text(),
    description = $('.object-description .inner'),
    generalInfo = $('.object-description').next().find('.bd'),
    homepage = $('a[alt="Hjemmeside"]').attr('href'),
    phone = $('dt:contains(Telefon)').next().text().trim();

  if(price) {
    price = price.split('Pris: ')[1];
  }

  async.map([description, generalInfo], function(field, cb) {
    if(field) {
      return getText($, description, false, function(err, d) {
        if(err) {
          return cb(err);
        }

        cb(null, d);
      });
    }

    cb();
  }, function(err, d) {
    if(err) {
      return cb(err);
    }

    cb(null, {
      title: title,
      price: price,
      description: d[0] || '',
      generalInfo: d[1] || '',
      homepage: homepage,
      phone: phone
    });
  });
};

