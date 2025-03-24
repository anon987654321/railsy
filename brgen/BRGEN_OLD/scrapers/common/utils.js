var fs = require('fs');

function read(name, cb) {
  var path = './tests/data/' + name + '.html';

  fs.readFile(path, {
    encoding: 'utf-8'
  }, function(err, d) {
    if(err) return console.error('Failed to read', path);

    cb(d);
  });
}
exports.read = read;

