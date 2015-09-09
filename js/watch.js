var google = require('googleapis');

exports.start = function(auth, callback) {
    /**
     * watch
     *
     * @param {google.auth.OAuth2} auth An authorized OAuth2 client.
     */
    var gmail = google.gmail('v1');
    gmail.users.watch({
        auth: auth,
        userId: 'me',
        resource: {
            'topicName': "projects/gitjob-1020/topics/newThread",
            'labelIds': ["INBOX"]
        }
    }, function (err) {
        if (err) {
            console.log('The API returned an error: ' + err);
        }
        else {
            gmail.users.getProfile({
                auth: auth,
                userId: 'me'
            }, function (err, response) {
                if (err) {
                    console.log('Could not find userinfo for authenticated user: ' + err);
                }
                else {
                    console.log("Found userinfo for " + response.emailAddress);
                    console.log("Successfully sent request for watch");
                    callback(response);
                }
            });
        }
    });
};