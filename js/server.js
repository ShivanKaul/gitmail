// Load the http module to create an http server.
var http = require('http');
var fs = require('fs');
var request = require('request');
var pubsub = require('./pubsub.js');

// Watch command

console.log("Sending watch command...");

//request.post({
//
//    url: 'https://www.googleapis.com/gmail/v1/users/me/watch',
//    headers: {
//        'content-type': 'application/json',
//        'Authorization': 'Bearer '+ " "
//    },
//    scope: [
//        'https://mail.google.com/'
//    ],
//
//    'body': JSON.stringify({
//        'topicName': "/projects/gitjob-1020/topics/newThread",
//        'labelIds': ["INBOX"]
//    })
//}, function(error, resp, body){
//    if (error) {
//        console.log("Got error while sending watch request request");
//        console.log(error)
//    }
//    else {
//        console.log("Got response!");
//        console.log(resp)
//    }
//});

var server = http.createServer(function (req, responseToSend) {

    //pubsub.run();


    var file = req.url;
    //
    //var filePrefix = '/../htdocs';
    //
    if (file == '/') {
        pubsub.start();
        //console.log("HIT END POINT, REQ IS");
        //console.log(req);
        //pubsub.receivedMessage(req);
    }
    //else if (file == '/newThread') {

        //console.log("HIT END POINT, REQ IS");
        //console.log(req);
        ////pubsub.newThread();
        //pubsub.receivedMessage(req);
    //}

    responseToSend.end();

    //
    //if (file == '/googlec2f8f617ad7e80e0.html') {
    //    file = '/googlec2f8f617ad7e80e0.html';
    //}
    //
    //fs.readFile(__dirname + filePrefix + file,
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

});

server.listen(process.env.PORT || 8080);

console.log("Port currently being used is: " + (process.env.PORT || 8080));