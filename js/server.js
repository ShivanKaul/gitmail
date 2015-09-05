var http = require('http');
var auth = require('./auth');
var htdocs = '/../htdocs';
var fs = require('fs');
var watch = require('./watch');
var history = require('./history');
var pubsub = require('./pubsub');
var rootdir = __dirname + '/../';


var lastHistoryId = 4033514, // ohmygodwat
    newHistoryId;

var server = http.createServer(function (req, responseToSend) {

    var file = req.url;

    if (req.method == 'POST' && file == '/receive') {
        var body = '';
        req.on('data', function(chunk) {
            console.log("Received body data:");
            body += chunk.toString()//console.log(chunk.toString());
        });
        req.on('end', function() {
            if (body != '') {
                console.log(body)
                var json = JSON.parse(body);
                var message = new Buffer(json.message.data, 'base64');
                console.log(JSON.parse(message))
                var userId = JSON.parse(message).emailAddress;
                console.log(userId)
                newHistoryId = JSON.parse(message).historyId;
                auth.setup(history.list, lastHistoryId)
                lastHistoryId = newHistoryId
            }

        })
        console.log("HIT END POINT, REQ IS");
    }
    if (file == '/') {
        auth.setup(watch.start)
    }

    //else if (file == '/receive') {
    //
    //    var body = '';
    //    req.on('data', function (data) {
    //        body += data;
    //    });
    //    console.log(body)
    //    console.log("HIT END POINT, REQ IS");
    //    //pubsub.receivedMessage(req);
    //}

    //else if (file == '/googlec2f8f617ad7e80e0.html') {
    //
    //    file = '/googlec2f8f617ad7e80e0.html';
    //}

    else if (file.match(/authenticated*/)) {
        var access_token = file.split("code=")[1];
        responseToSend.write("Authenticated!");
        auth.useAccessToken(access_token, watch.start)
    }

    //fs.readFile(__dirname + htdocs + file,
    //    function (err, data) {
    //        if (err) {
    //            console.log(err);
    //            responseToSend.writeHead(500);
    //            return responseToSend.end('Error loading index.html');
    //        }
    //
    //        responseToSend.writeHead(200);
    //        responseToSend.end(data);
    //    });

    responseToSend.end();

});

server.listen(process.env.PORT || 8080);

console.log("Port currently being used is: " + (process.env.PORT || 8080));