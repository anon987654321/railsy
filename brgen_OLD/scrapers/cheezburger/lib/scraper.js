'use strict';

var _url = require('url'),
  querystring = require('querystring');

var async = require('async'),
  cheerio = require('cheerio'),
  upndown = require('upndown'),
  moment = require('moment');

var savePhotos = require('../../common/save_photos');

var und = new upndown();

module.exports = function(o, data, cb) {
  var $ = cheerio.load(data.text);

  savePhotos(getPhotos($), o, function(err, photos) {
    if(err) {
      return cb(err);
    }

    cb(null, [{
      subject: data.subject,
      posts_attributes: [{
        text: getText($),
        'scraped_at': moment().utc().format(),
        'sources': getSources($),
        'photos_attributes': photos
      }]
    }]);
  });
};

function getText($) {
  var $root = $.root(),
    desc = $root.find('.pb_feed').parent().next().html(),
    description = (desc && und.convert(desc)) || '',
    src,
    qs;

  description = description && description + '\n';

  var $video = $root.find('.video-embed');
  src = $video.attr('src');

  if($video.length && src) {
    return description + src.split('?')[0];
  }

  var $vine = $root.find('.vine-embed');
  src = $vine.attr('src');

  if($vine.length && src) {
    return description + src.split('/embed')[0];
  }

  var $embedly = $root.find('.embedly-embed');
  src = $embedly.attr('src');

  if($embedly.length && src) {
    qs = querystring.parse(_url.parse(src).search) || {};

    return description + qs.url;
  }

  return description;
}

function getSources($) {
  var $root = $.root(),
    $e = $('*:contains("Submitted by")');

  var parts = [];

  $e.find('a').each(function(i, e) {
    var $e = $(e);

    parts.push({
      name: $e.text(),
      url: $e.attr('href')
    });
  });

  return parts;
}

function getPhotos($) {
  var $root = $.root(),
    $img = $root.find('.js-img-link img, .event-item-lol-image');

  if($img.length) {
    return $img.map(function(i, e) {
      return $(e).attr('src');
    }).get();
  }

  return [];
}

