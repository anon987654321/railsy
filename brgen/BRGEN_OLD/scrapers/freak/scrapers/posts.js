'use strict';

var path = require('path');

var async = require('async'),
  cheerio = require('cheerio'),
  moment = require('moment');

var getText = require('../../common/get_text');

module.exports = function(data, cb) {
  var $ = cheerio.load(data);
  var subject = $('title').text().split('-').slice(0, -1).join('').trim();

  async.map($('#posts table').toArray(), function(p, cb) {
    var $p = $(p),
      $el = $p.find('tr[valign="top"]'),
      $alt2 = $el.find('.alt2'),
      $alt1 = $el.find('.alt1');

    if(!$alt1[0]) {
      return;
    }

    // Only posts have ids

    if(!$alt1[0].attribs.id) {
      return;
    }

    var replyId = getReplyId($el);

    $el = $alt1.children('div').last();

    var photos = [];

    $el.find('img').each(function(i, el) {
      var src = $(el).attr('src');

      if(path.extname(src) !== '.gif') {
        photos.push(src);
      }
    });

    $el.find('img').parent().remove();

    // Remove quotes
    $el.find('.quotetop').parent().parent().remove();

    getText($, $el, false, function(err, text) {
      cb(null, {
        date: parseDate($, $p),
        avatar: $alt2.find('img').attr('src'),
        scraped_post_id: getPostId($el),
        reply_to_scraped_post_id: replyId,
        text: text,
        'photos_attributes': photos
      });
    });
  }, function(err, posts) {
    if(err) {
      return cb(err);
    }

    if(!posts) {
      return cb(new Error('Id not found'));
    }

    cb(null, {
      date: posts[0].date,
      subject: subject,
      posts: posts
    });
  });
};

function parseDate($, $el) {
  var parts = $el.find('.thead').first().text().trim().split(' ');

  var time,
    hour,
    minute;

  if(parts[0] === 'I') {
    var today = moment();

    if(parts[1] === 'går,') {
      time = parts[2].split(':');
      hour = parseInt(time[0], 10);
      minute = parseInt(time[1], 10);

      var yesterday = today.add(-1, 'days');

      yesterday.hours(hour).minutes(minute).seconds(0);

      return yesterday.utc().format();
    }

    if(parts[1] === 'dag,') {
      time = parts[2].split(':');
      hour = parseInt(time[0], 10);
      minute = parseInt(time[1], 10);

      today.hours(hour).minutes(minute).seconds(0);

      return today.utc().format();
    }

    return;
  }

  var day = parseInt(parts[0].split('.')[0], 10),
    month = parseInt(parseMonth(parts[1]), 10),
    year = parseInt(parts[2], 10);

  time = parts[3].split(':');
  hour = parseInt(time[0], 10);
  minute = parseInt(time[1], 10);

  return moment([year, month, day, hour, minute]).utc().format();
}

function parseMonth(str) {
  return [
    'januar',
    'februar',
    'mars',
    'april',
    'mai',
    'juni',
    'juli',
    'august',
    'september',
    'oktober',
    'november',
    'desember'
  ].indexOf(str);
}

function getPostId($el) {
  var id = $el.parents('table').children('tr').first().find('a').last().attr('id');

  if(id) {
    return id.split('postcount')[1];
  }
}

function getReplyId($el) {
  var href = $el.find('.quotetop a').first().attr('href');

  if(href) {
    return href.split('#')[1].split('post')[1];
  }
}

