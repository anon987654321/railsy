'use strict';

var url = require('url');

var getMarkdown = require('./get_markdown'),
  emoticons = require('./emoticons');

module.exports = getText;

function getText($, $e, doubleBreaks, cb) {
  if(!$e) {
    return cb(null, '');
  }

  ['strong', 'h1', 'h2', 'h3', 'h4'].forEach(removeEmpties.bind(null, $, $e));

  $('.remove').remove();

  replaceWithContent($, $e, 'u', function($e) {
    return '<b>' + $e.text() + '</b>';
  });

  replaceWithContent($, $e, 'img.bbc_emoticon, img.bbc_img, img.inlineimg', function($e) {
    var name = $e.attr('src').split('/').slice(-1)[0];

    return emoticons[name];
  });

  replaceWithContent($, $e, 'span', function($e) {
    return $e.text();
  });

  if(doubleBreaks) {
    replaceWithContent($, $e, 'br', function() {
      return '<br /><br />';
    });
  }

  var $iframe = $e.find('iframe');

  $iframe.replaceWith(function(i) {
    return url.resolve('http://', $($iframe[i]).attr('src'));
  });

  var html = $e.html();

  if(!html) {
    return cb(null, '');
  }

  getMarkdown(html.trim(), function(err, d) {
    if(err) {
      return cb(err);
    }

    d = d.replace(/<(https?:\/\/[\S]+)>/g, function(_, g) {return g;}).
      replace(/<div>/g, '').replace(/<\/div>/g, '');

    if(doubleBreaks) {
      return cb(null, d.replace(/\n\n\n/g, '\n\n'));
    }

    // `** foobar **` => `**foobar**`
    d = d.replace(/\*\*(.*)\*\*/g, function(m, p) {return '**' + p.trim() + '**';});

    cb(null, d);
  });
}

function removeEmpties($, $e, name) {
  replaceWithContent($, $e, name, function($e) {
    var text = $e.text().trim();

    if(text && text !== '&nbsp;') {
      return '<' + name +'>' + text + '</' + name + '>\n';
    }

    return '<div class="remove"></div>';
  });
}

function replaceWithContent($, $elem, name, cb) {
  var $e = $elem.find(name);

  $e.replaceWith(function(i) {
    return cb($($e[i]));
  });
}
getText.replaceWithContent = replaceWithContent;

