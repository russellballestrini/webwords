var express = require('express');
var request = require('request');
var app = express();
app.get('/', function (req, res) {
  var keyword = req.query.keyword;
  var target = req.query.target;
  request(target, function (error, response, body) {
    if (body.includes(keyword)) {
	  res.send('true');
    }
	else {
	  res.send('false');
	}
  });
});
app.listen(8888, function () {
  console.log('listening on 0.0.0.0:8888');
});
