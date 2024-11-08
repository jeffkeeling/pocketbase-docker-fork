// pb_hooks/main.pb.js

onRecordAfterCreateRequest((e) => {
  const message = new MailerMessage({
    from: {
      address: $app.settings().meta.senderAddress,
      name: $app.settings().meta.senderName,
    },
    to: [{ address: process.env.EMAIL_RECIPIENT }],
    subject: `New Message from ${process.env.SITE_NAME}`,
    html: `
      New Message from ${process.env.SITE_NAME} <br>

      Name: ${e.record.get('name')}<br>
      
      Email: ${e.record.get('email')}<br>

      Message: ${e.record.get('message')}<br>
  	`,
    // bcc, cc and custom headers are also supported...
  })

  $app.newMailClient().send(message)
}, 'messages')
