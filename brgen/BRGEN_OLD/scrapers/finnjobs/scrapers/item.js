'use strict';

var cheerio = require('cheerio'),
  getText = require('../../common/get_text');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    $description = $('#description .bd');

  if($description) {
    return getText($, $description, false, function(err, description) {
      if(err) {
        return cb(err);
      }

      cb(null, scrape($, description))
    });
  }

  cb(null, scrape($, ''));
};

function scrape($, description) {
  return {
    title: $('header h1').text(),
    description: description,
    titles: scrapeTitles($, $('.contactinfo')),
    company: $('*[data-automation-id="position-information"] dd').first().text(),
    address: scrapeAddress($),
    jobTitle: $('dt:contains("Tittel")').next().text(),
    starts: $('dt:contains("Tiltredelse")').next().text(),
    sector: $('dt:contains("Sektor")').next().text(),
    duration: $('dt:contains("Varighet")').next().text(),
    positions: $('dt:contains("Stillinger")').next().text()
  };
}

function scrapeAddress($) {
  return {
    address: $('*[data-automation-id="workplace"]').first().text(),
    po: $('*[data-automation-id="workplace"]').last().text(),
  };
}

function scrapeTitles($, $info) {
  return $info.map(function(i, e) {
    return {
      name: $(e).find('h3').text(),
      position: $(e).find('.neutral.mtn').first().text(),
      phone: $(e).find('dd').first().text()
    };
  });
}

