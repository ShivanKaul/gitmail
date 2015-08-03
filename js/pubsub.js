var gcloud = require('gcloud');
var pubsub;

pubsub = gcloud.pubsub({
    projectId: 'gitjob-1020',
    credentials: {
        private_key: process.env.PRIVATE_KEY,
        client_email: process.env.CLIENT_EMAIL
    }
});


// Create a new topic.
pubsub.createTopic('projects/gitjob-1020/topics/newThread', function(err, topic, apiResponse) {
    console.log("api response on creating topic is " + apiResponse)
    console.log("topic on creating topic is " + topic)
});

// Reference an existing topic.
var topic = pubsub.topic('projects/gitjob-1020/topics/newThread');

// Publish a message to the topic.
topic.publish('New message!', function(err) {

});

topic.('pubsub_policy.json');

// Subscribe to the topic.
topic.subscribe('new-subscription', function(err, subscription, apiResponse) {
    // Register listeners to start pulling for messages.
    function onError(err) {
        console.log("Got an error :( " + err);
    }
    function onMessage(message) {
        console.log("Message is " + message);
    }
    subscription.on('error', onError);
    subscription.on('message', onMessage);

    // Remove listeners to stop pulling for messages.
    subscription.removeListener('message', onMessage);
    subscription.removeListener('error', onError);
});