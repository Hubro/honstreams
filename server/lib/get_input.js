(function() {
  var get_input;

  get_input = function(prompt, callback) {
    var stdin, stdout;
    stdin = process.stdin;
    stdout = process.stdout;
    stdin.resume();
    stdin.setEncoding('utf8');
    stdout.write("" + prompt + " > ");
    return stdin.once('data', function(data) {
      data = String(data).trim();
      if (data) {
        stdin.pause();
        return callback(data);
      } else {
        return get_input(prompt, callback);
      }
    });
  };

  module.exports = get_input;

}).call(this);
