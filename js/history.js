var google = require('googleapis');
var redis = require('./redis');


exports.list = function (auth, startHistoryId) {
    /**
     * list
     *
     * @param {google.auth.OAuth2} auth An authorized OAuth2 client.
     */
    var gmail = google.gmail('v1');
    gmail.users.history.list({
        auth: auth,
        labelId: "INBOX",
        userId: 'me',
        startHistoryId: startHistoryId
    }, function (err, response) {
        if (err) {
            console.log('Error while listing history ' + err);
        }
        else {
            console.log("Successfully sent request for listing history");
            //console.log(response);
            var latest_messageId = response.history[response.history.length - 1].messages[0].id;

            gmail.users.messages.get({
                auth: auth,
                userId: 'me',
                id: latest_messageId

            }, function (err, response) {
                if (err) {
                    console.log('Error while getting message: ' + err);
                }
                else {
                    console.log("Successfully sent request for getting message");
                    var headers = response.payload.headers;
                    var parts = response.payload.parts;

                    console.log(response.payload);

                    var subject,
                        date,
                        from;

                    // Get relevant headers
                    for (var i = 0; i < headers.length; i++) {
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

                    date = (new Date(date)).toISOString();

                    var name = from.substring(0, from.indexOf('<')).trim();
                    var email = from.substring(from.indexOf('<') + 1, from.indexOf('>')).trim();
                    var body;
                    console.log(subject);
                    console.log(parts);

                    if (parts) {
                        body = (new Buffer(parts[0].body.data, 'base64')).toString();
                    }
                    else {
                        body = (new Buffer(response.payload.body.data, 'base64')).toString();
                    }

                    console.log(body);
                    redis.unshift(date, name, email, subject, body)
                }
            })
        }
    });
};