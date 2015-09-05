var google = require('googleapis');

exports.list = function(auth, startHistoryId) {
    /**
     * list
     *
     * @param {google.auth.OAuth2} auth An authorized OAuth2 client.
     */
    var gmail = google.gmail('v1');
    gmail.users.history.list({
        auth: auth,
        userId: 'me',
        startHistoryId: startHistoryId
    }, function (err, response) {
        if (err) {
            console.log('The API returned an error: ' + err);
            return;
        }
        else {
            console.log("Successfully sent request for listing history");
            console.log(response)
        }

    });
};