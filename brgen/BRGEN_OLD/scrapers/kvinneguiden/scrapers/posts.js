'use strict';

var async = require('async'),
  cheerio = require('cheerio'),
  moment = require('moment');

var getText = require('../../common/get_text');

module.exports = function(data, cb) {
  var $ = cheerio.load(data),
    subject = $('h1.ipsType_pageTitle').text().trim(),
    date = moment($('.ipsType_blendLinks time').attr('datetime'), 'YYYY-MM-DD').utc().format();

  $('.edit, .signature, .attachment').remove();

  async.map($('.cPost').toArray(), function(e, cb) {
    var $e = $(e),
      $content = $e.find('*[data-role="commentContent"]'),
      poster = getPoster($e),
      replyId = getReplyId($content),
      photos = [];

    $content.find('img:not(.bbc_emoticon)').each(function(i, el) {
      var $el = $(el);

      if($el.parent().hasClass('resized_img')) {
        photos.push($el.parent().attr('href'));
      }
      else {
        photos.push($el.attr('src'));
      }
    }).remove();

    // .resized_img
    /*
    $content.find('.resized_img').each(function(i, el) {
      photos.push($(el).attr('href'));
    }).remove();
    */

    // Anonymous hashes

    $content.find('.bbc').parent().remove();
    $content.find('.citation, .ipsBlockquote, span[rel="lightbox"], .bbc').remove();

    getText($, $content, false, function(err, text) {
      if(err) {
        return cb(err);
      }

      cb(null, {
        avatar: getAvatar($e),
        poster: poster,
        date: moment($e.find('time').attr('datetime'), 'YYYY-MM-DD').utc().format(),
        text: text,
        photos_attributes: photos,
        scraped_post_id: $e.attr('id').split('_').slice(-1)[0],
        //reply_to_scraped_post_id: replyId
      });
    });
  }, function(err, posts) {
    if(err) {
      return cb(err);
    }

    if(!posts.length) {
      return cb(new Error('Id not found'));
    }

    cb(null, {
      date: date,
      subject: subject,
      posts: posts
    });
  });
};

function getAvatar($e) {
  var img = $e.find('.ipsUserPhoto img').attr('src').split('?')[0];

  if(img.split('/').slice(-1)[0] !== 'default_large.png') {
    return img;
  }
}

function getPoster($e) {
  return $e.find('*[itemprop="creator"]').text().trim();
}

function getReplyId($e) {
  return $e.find('blockquote').attr('data-cid');
}

