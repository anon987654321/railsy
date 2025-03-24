'use strict';

var async = require('async'),
  cheerio = require('cheerio'),
  moment = require('moment');

var getText = require('../../common/get_text');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    subject = $('.ipsType_pagetitle').text(),
    date = moment($('*[itemprop="dateCreated"]').attr('datetime'), 'YYYY-MM-DD').utc().format();

  // Remove `last edited`
  $('.edit').remove();

  async.map($('div[itemprop="commentText"]').toArray(), function(el, cb) {
    var $el = $(el),
      $wrap = $el.parents('.post_wrap'),
      replyId = getReplyId($el);

    $el.find('.ipsBlockquote, .citation').remove();

    getText($, $el, true, function(err, text) {
      if(err) {
        return cb(err);
      }

      cb(null, {
        text: text,
        date: getDate($, $el.parent()),
        'photos_attributes': getPhotos($, $el),
        avatar: getAvatar($wrap),
        scraped_post_id: getPostId($wrap),
        reply_to_scraped_post_id: replyId
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
      date: date,
      subject: subject,
      posts: posts
    });
  });
};

function getDate($, $el) {
  return moment($el.find('.published').attr('title')).utc().format();
}

function getPhotos($, $el) {
  var ret = [];

  $el.find('img[itemprop="image"]').each(function(i, el) {
    ret.push('http:' + $(el).parent().attr('href'));
  });

  return ret;
}

function getAvatar($el) {
  var src = $el.find('.avatar img').attr('src'),
    ret = src.split('?')[0];

  if(src.indexOf('default_large.png') >= 0) {
    return;
  }

  if(ret.indexOf('http://') === 0) {
    return ret;
  }

  return 'http:' + ret;
}

function getPostId($el) {
  return $el.find('*[itemprop="replyToUrl"]').attr('data-entry-pid');
}

function getReplyId($el) {
  var $blockquote = $el.find('.ipsBlockquote');

  if($blockquote) {
    return $blockquote.attr('data-cid');
  }
}

