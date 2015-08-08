var http = require('http');
var auth = require('./auth');
var watch = require('./watch');
var pubsub = require('./pubsub');
var rootdir = __dirname + '/../';


var server = http.createServer(function (req, responseToSend) {

    var file = req.url;

    if (file == '/') {
        auth.setup(watch.start)
    }

    else if (file == '/newThread') {

        console.log("HIT END POINT, REQ IS");
        console.log(req);
        //pubsub.receivedMessage(req);
    }

    else if (file.match(/authenticated*/)) {
        var access_token = file.split("code=")[1];
        responseToSend.write("Authenticated!");
        auth.useAccessToken(access_token, watch.start)
    }

    responseToSend.end();

});

server.listen(process.env.PORT || 8080);

console.log("Port currently being used is: " + (process.env.PORT || 8080));