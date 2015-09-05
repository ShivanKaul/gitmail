var http = require('http');
var auth = require('./auth');
var watch = require('./watch');
var history = require('./history');

lastHistoryId = 4035105; // ohmygodwat
newHistoryId = lastHistoryId + 1; //OHMYGODWAT

var server = http.createServer(function (req, responseToSend) {

    var file = req.url;

    if (file == '/') {
        auth.setup(watch.start);
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
                auth.setup(history.list, lastHistoryId);
                lastHistoryId = newHistoryId;
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