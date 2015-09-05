var google = require('googleapis');

exports.start = function(auth) {
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
    }, function (err, response) {
        if (err) {
            console.log('The API returned an error: ' + err);
            return;
        }
        else {
            console.log("Successfully sent request for watch");
            console.log(response)
        }
    });
};