Meteor.startup ->
  send_mail()

send_mail = ->
  if SendgridConfig?
    server  = EmailJS.server.connect
       user: SendgridConfig.user_name
       password: SendgridConfig.password
       host:    "smtp.sendgrid.com"
       ssl:     true

    # send the message and get a callback with an error or details of the message that was sent
    server.send {
       text:    "i hope this works", 
       from:    "you <tom@thesnail.org>", 
       to:      "you <tom@thesnail.org>",
       subject: "testing emailjs"
    }, (err, message) -> console.log(err || message)