var express = require('express');
var server = express();
var auth = require('./auth');
var watch = require('./watch');
var history = require('./history');
var path = require('path');
var project_folder = __dirname + '/../';

var bodyParser = require('body-parser');
server.use( bodyParser.json() );
//server.use(express.json());

server.use(express.static(project_folder + 'css'));
server.use(express.static(project_folder + 'htdocs'));

// Routes
server.get('/', function (req, res) {
    res.sendFile('index.html')
});

server.post('/beginAuth', function (req, res) {
    auth.getAuthUrl(function(authUrl) {
       res.redirect(authUrl);
    });
});

server.get('/authenticated', function (req, res) {
    var access_token = req.query.code;
    auth.useAccessToken(access_token, watch.start);
    res.redirect('done');
});

server.get('/done', function (req, res) {
    res.sendFile(path.resolve(project_folder) + '/htdocs/finishedAuth.html');
});

server.post('/receive', function(req, res) {

    var message = new Buffer(req.body.message.data, 'base64');
    console.log(req.body);

    auth.fetchOAuth(req.body.email, history.list)

});

console.log("Port currently being used is: " + (process.env.PORT || 8080));

server.listen(process.env.PORT || 8080);
