'use strict';

var qs = require('querystring');

var async = require('async'),
  request = require('./request');

var savePhotos = require('./save_photos');

module.exports = function(scrapers, encoding) {
  return function(config, url, cb) {
    _posts(config, url, cb, [], []);
  };

  function _posts(config, url, cb, posts, meta) {
    request(url, {
      encoding: encoding
    }, function(err, html) {
      if(err) {
        return cb(err);
      }

      scrapers.posts(html, function(err, data) {
        if(err) {
          return cb(err);
        }

        async.map(data.posts, function(post, cb) {
          savePhotos(post['photos_attributes'], config, function(err, d) {
            if(err) {
              return cb(err);
            }

            // TODO: Remove avatars altogether

            cb(null, {
              'avatar': null,
              'scraped_at': post.date,
              'poster': post.poster,
              'text': post.text,
              'photos_attributes': d
            });
          });
        }, function(err, newPosts) {
          if(err) {
            return cb(err);
          }

          posts = posts.concat(newPosts);

          meta.push({
            'subject': data.subject,
            'url': url
          });

          scrapers.get_next_page(html, function(err, next) {
            if(next) {
              _posts(config, next, cb, posts, meta);
            }
            else {
              if(posts.length > 0) {
                posts.sources = [
                  {
                    'name': config.site,
                    'url': meta[0].url
                  }
                ];

                return cb(null, {
                  'id': qs.decode(url).showtopic,
                  'subject': meta[0].subject,
                  'posts_attributes': posts,
                  'scraped_at': data.date
                });
              }
              else {
                console.warn('Failed to parse topic', url);

                cb();
              }
            }
          });
        });
      });
    });
  }
};

