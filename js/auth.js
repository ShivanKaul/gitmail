var rootdir = __dirname + '/../';
var fs = require('fs');
var googleAuth = require('google-auth-library');

// MongoDB
var MongoClient = require('mongodb').MongoClient;
var url = 'mongodb://localhost:27017';

function createOAuth2Object(callback) {
    // Load client secrets from a local file.
    fs.readFile(rootdir + '.credentials/client_secret.json', function processClientSecrets(err, content) {
        if (err) {
            console.log('Error loading client secret file: ' + err);
            return;
        }
        var credentials = JSON.parse(content);

        var clientSecret = credentials.web.client_secret;
        var clientId = credentials.web.client_id;
        var redirectUrl = credentials.web.redirect_uris[1];
        var auth = new googleAuth();
        callback(new auth.OAuth2(clientId, clientSecret, redirectUrl));
    });
}

function fetchToken(email, callback) {
    MongoClient.connect(url, function(err, db) {
        console.log("Connected correctly to server for fetching.");

        var collection = db.collection('access_tokens');
        collection.findOne(
            {
                email: email
            }, function(err, doc) {
                if (err) {
                    console.log("Couldn't fetch access token from MongoDB.")
                }
                else {
                    callback(doc.email, doc.historyId);
                }
            });
    });
}

exports.fetchOAuth = function(email, callback) {
    createOAuth2Object(function(oAuth2Client) {
        fetchToken(email, function(token, historyId) {
            oAuth2Client.credentials = token;
            callback(oAuth2Client, historyId);
        })
    })
};

exports.getAuthUrl = function(callback) {
    var SCOPES = ['https://www.googleapis.com/auth/gmail.readonly'];

    createOAuth2Object(function(oauth2Client) {
        var authUrl = oauth2Client.generateAuthUrl({
            access_type: 'offline',
            scope: SCOPES
        });
        callback(authUrl);
    })
};

exports.useAccessToken = function(code, callback) {
    createOAuth2Object(function(client) {
        client.getToken(code, function(err, token) {
            if (err) {
                console.log('Error while trying to retrieve access token', err);
                return;
            }
            client.credentials = token;
            callback(client, function(response) {
                console.log("Trying to store token");
                storeToken(token, response.emailAddress, response.historyId);
            });
        });
    })
};

/**
 * Store token to disk be used in later program executions.
 *
 * @param {Object} token The token to store to disk.
 * @param {Object} email The user's email.
 * @param {Object} historyId The historyId on the user's inbox at the time of setting the watch.
 */
function storeToken(token, email, historyId) {

    MongoClient.connect(url, function(err, db) {
        console.log("Connected correctly to server");

        var collection = db.collection('access_tokens');
        collection.updateOne(
            {
                email: email
            },
            {
                email: email,
                historyId: historyId,
                token: token
            },
            {
                upsert: true
            }, function(err) {
                if (err) {
                    console.log("Couldn't save access token, MongoDB is the SnapChat of databases.")
                }
            });
    });
}
