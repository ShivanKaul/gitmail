var redis = require("redis"),
    client = redis.createClient();

exports.unshift = function(date, name, email, subject, body) {
    var item = {
        sendDate: date,
        senderName: name,
        senderEmail: email,
        messageContents: body,
        messageSubject: subject
    }
    client.lpush('messages', JSON.stringify(item))
}