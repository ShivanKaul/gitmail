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
pubsub.createTopic('projects/gitjob-1020/topics/newThread', function(err, topic) {});

// Reference an existing topic.
var topic = pubsub.topic('newThread');

// Publish a message to the topic.
topic.publish('New message!', function(err) {});

// Subscribe to the topic.
topic.subscribe('new-subscription', function(err, subscription) {
    // Register listeners to start pulling for messages.
    function onError(err) {}
    function onMessage(message) {}
    subscription.on('error', onError);
    subscription.on('message', onMessage);

    // Remove listeners to stop pulling for messages.
    subscription.removeListener('message', onMessage);
    subscription.removeListener('error', onError);
});