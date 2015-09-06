var redis = require("redis"),
    client = redis.createClient();

exports.unshift = function(date, name, email, subject, body) {
    var item = {
        sendDate: date,
        senderName: name,
        senderEmail: email,
        messageContents: body,
        messageSubject: subject,
        tag: 'IncomingEmail'
    };

    client.lrange('processed_messages', 0, 0, function(err, value) {
        if (err) {
            console.log("Couldn't read head element: " + error)
        }
        else {
            if (value.length < 1) {
                client.lpush('messages', JSON.stringify(item));
                console.log("Inserted into new redis list")
            }
            else {
                var peek =  JSON.parse(value[0]);
                if (peek.sendDate < date) {
                    console.log("New email!");
                    client.lpush('messages', JSON.stringify(item))
                }
                else {
                    console.log("New email's date " + date);
                    console.log("Redis email's date " + peek.sendDate);
                    console.log("Older email than the one in redis");
                }
            }
        }
    })
};
