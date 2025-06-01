var cheerio = require('cheerio');

module.exports = function(data, cb) {
  var $e = cheerio.load(data);

  if($e('.ipsPagination_next').hasClass('ipsPagination_inactive')) {
    return cb(new Error('URL not found'));
  }

  var url = $e('.ipsPagination_next a').attr('href');

  if(url) {
    return cb(null, url);
  }

  cb(new Error('URL not found'));
};

