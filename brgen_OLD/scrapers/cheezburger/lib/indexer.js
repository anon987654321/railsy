'use strict';

var fs = require('fs'),
  request = require('request'),
  FeedParser = require('feedparser');

module.exports = main;

function main(o, cb) {
  parseRssUrl(o, function(err, url) {
    if(err) {
      return cb(err);
    }

    var feedparser = new FeedParser(),
      req = request(url);

    req.on('error', cb);
    req.on('response', function(res) {
      var stream = this;

      if (res.statusCode != 200) {
        return this.emit(
          'error',
          new Error('Bad status code')
        );
      }

      stream.pipe(feedparser);
    });

    var result = [];

    feedparser.on('error', cb);
    feedparser.on('readable', function() {
      var stream = this;

      var item, title, description, date, url;

      while(item = stream.read()) {
        title = item.title;
        description = item.description;
        date = item.date;
        url = item.origlink;

        result.push({
          subject: item.title,
          text: item.description,
          date: item.date,
          url: item.origlink
        });
      }
    });
    feedparser.on('end', function() {

      // Pass parsed data to the scraper instead of URL

      cb(null, result);
    });
  })
};

main.parseRssUrl = parseRssUrl;

function parseRssUrl(o, cb) {
  var category = o.category;

  if(!category) {
    return cb(new Error('Missing category'));
  }

  cb(null, 'http://feeds.feedblitz.com/' + o.category);
}

