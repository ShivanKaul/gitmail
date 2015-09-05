var google = require('googleapis');
var redis = require('./redis');


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
            console.log('Error while listing history ' + err);
            return;
        }
        else {
            console.log("Successfully sent request for listing history");
            console.log(response);
            var latest_messageId = response.history[response.history.length - 1].messages[0].id
            console.log("message id is " + latest_messageId);

            gmail.users.messages.get({
                auth: auth,
                userId: 'me',
                id: latest_messageId

            }, function (err, response) {
                if (err) {
                    console.log('Error while getting message: ' + err);
                    return;
                }
                else {
                    console.log("Successfully sent request for getting message");
                    console.log(response)
                    var headers = response.payload.headers
                    var parts = response.payload.parts

                    var subject,
                        date,
                        from;

                    for (i = 0 ; i<headers.length; i++) {
                        if (headers[i].name === 'Subject') {
                            subject = headers[i].value;
                        }
                        else if (headers[i].name === 'Date') {
                            date = headers[i].value;
                        }
                        else if (headers[i].name === 'From') {
                            from = headers[i].value;
                        }
                    }

                    var name = from.substring(0, from.indexOf('<')).trim()
                    var email = from.substring(from.indexOf('<') + 1, from.indexOf('>')).trim()

                    var body = (new Buffer(parts[0].body.data, 'base64')).toString()
                    redis.unshift(date, name, email, subject, body)


                }
            })

            //for (i = 0 ; i<response.history.length; i++) {
            //    console.log(response.history[i])
            //    console.log("")
            //}

            //var latest_message = response.history[response.history.length - 3].messages;
            //console.log(latest_message);
            //console.log(latest_message.internalDate);

        }

    });
};