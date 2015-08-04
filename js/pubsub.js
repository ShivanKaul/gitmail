var gcloud = require('gcloud');
var request = require('request');

var pubsub = gcloud.pubsub({
    projectId: 'gitjob-1020',
    credentials: {
        private_key: process.env.PRIVATE_KEY,
        //private_key_id: process.env.PRIVATE_KEY_ID,
        //client_id: process.env.CLIENT_ID,
        //type: process.env.TYPE,
        client_email: process.env.CLIENT_EMAIL
    }
    //keyFilename: __dirname + '/../gitjob-7997d2f90025.json'
});

exports.start = function () {

// Create a new topic.
    pubsub.createTopic('newThread7', function (err, topic, apiResponse) {
        console.log("trying to create topic")
        if (err) {
            console.log("Couldn't create a new topic because " + err)
        }
        else {
            console.log("no error while creating topic!")
            console.log("api response on creating topic is ")
            console.log(apiResponse)
            console.log("topic on creating topic is ")
            console.log(topic)
            // Subscribe to the topic.
            topic.subscribe('new-subscription7', function (err, subscription, apiResponse) {
                // Register listeners to start pulling for messages.
                function onMessage(message) {
                    console.log("Message is ");
                    console.log(message);
                }

                function onError(err) {
                    console.log("Got an error :( " + err);
                }
                if (err) {
                    console.log("Received error while subscribing to subscription " + err)
                }
                else {
                    console.log("No error while creating new subscription!")
                    subscription.on('error', onError);
                    subscription.on('message', onMessage);

                    // Remove listeners to stop pulling for messages.
                    //subscription.removeListener('message', onMessage);
                    //subscription.removeListener('error', onError);
                }
            });
        }
    });

    // Watch request
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
    //        'topicName': "/projects/gitjob-1020/topics/newThread7",
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
// Reference an existing topic.
//    var topic = pubsub.topic('newThread6');

//topic.('pubsub_policy.json');


};

exports.newThread = function () {
    var topic = pubsub.topic('newThread');

// Publish a message to the topic.
    topic.publish({
        data: 'New message!'
    }, function (err) {
        if (err) {
            console.log("Got error in publishing message to topic" + err)
        }
        else {
            console.log("Published message successfully!")
        }
    });
};

exports.receivedMessage = function (req) {
    console.log("message!")

};
