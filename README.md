# GitMail
> Every program attempts to expand until it can read mail.    
> \- Jamie Zawinski

Connect Gmail emails to GitHub repos. Every time you get an email in an authenticated Gmail inbox, a GitHub issue is created in a special repository named `gitmail`, with the email subject and body. Reply to an email by using special headers in a GitHub comment.

## Architecture
Two microservices - one each for GitHub and Gmail - connected by a Redis messaging FIFO. This architecture allowed us to split up the work easily and integration of the two services (one written in Node and the other in Haskell) was painless. Hosted on an EC2 instance.
