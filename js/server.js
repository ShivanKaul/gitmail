var http = require('http');
var auth = require('./auth');
var watch = require('./watch');
var history = require('./history');
var fs = require('fs');
var rootdir = __dirname + '/../';
var TOKEN_DIR = rootdir + '.credentials/';
var TOKEN_PATH = TOKEN_DIR + 'token.json';
lastHistoryId = 4040092; // ohmygodwat
newHistoryId = lastHistoryId + 1; //OHMYGODWAT

var server = http.createServer(function (req, responseToSend) {

    var file = req.url;
//    if (file.match(/*accounts\.google\.com*/)) {
//
//    }
    if (file == '/') {
        auth.setup(function(authUrl) { //watch.start,
            console.log(authUrl);
            responseToSend.writeHead(301, {
                'Location': authUrl
            });
            responseToSend.end();
        })
    }

    if (req.method == 'POST' && file == '/receive') {
        var body = '';
        req.on('data', function(chunk) {
            body += chunk.toString();
        });
        req.on('end', function() {
            if (body != '') {
                var json = JSON.parse(body);
                var message = new Buffer(json.message.data, 'base64');
                //var userId = JSON.parse(message).emailAddress;
                newHistoryId = JSON.parse(message).historyId;
                fs.readFile(TOKEN_PATH, function(err, token) {
                    if (err) {
                        console.log("Can't find token");
                        //getNewToken(oauth2Client, function(authUrl){
                        //    callback(authUrl);
                        //});
                        //callback(authUrl);
                    } else {
                        token = JSON.parse(token);
                        //if (token.expiry_date < Date.now()) {
                        //    getNewToken(oauth2Client, function(authUrl){
                        //        callback(authUrl);
                        //    });
                        //}

                        //oauth2Client.credentials = token;
                        console.log("Using previous token");
                        auth.send(history.list, lastHistoryId);
                        lastHistoryId = newHistoryId;
                    }
                });
                //history.list(lastHistoryId);
            }
        })
    }

    else if (file.match(/authenticated*/)) {
        var access_token = file.split("code=")[1];
        responseToSend.write("Authenticated! You can close this window.");
        auth.useAccessToken(access_token, history.list, lastHistoryId);
    }

    responseToSend.end();
});

server.listen(process.env.PORT || 8080);

console.log("Port currently being used is: " + (process.env.PORT || 8080));
