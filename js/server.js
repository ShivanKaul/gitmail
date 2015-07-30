// Load the http module to create an http server.
var http = require('http');
var fs = require('fs');

var server = http.createServer(function (req, responseToSend) {

    var file = req.url;

    var filePrefix = '/..';

    if (file == '/') {
        file = '/index.html';
    }

    if (file == '/googlec2f8f617ad7e80e0.html') {
        file = '/googlec2f8f617ad7e80e0.html';
    }

    fs.readFile(__dirname + filePrefix + file,
        function (err, data) {
            if (err) {
                console.log(err);
                responseToSend.writeHead(500);
                return responseToSend.end('Error loading index.html');
            }

            responseToSend.writeHead(200);
            responseToSend.end(data);
        });

});

server.listen(process.env.PORT || 8080);

console.log("Port currently being used is: " + (process.env.PORT || 8080));