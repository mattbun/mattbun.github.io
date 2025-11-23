---
title: "smtn"
author: "Matt Rathbun"
slug: "smtn"
tags:
  - smtn
  - smtp-pushover
  - go
  - linux
---

One of the unsung heroes of my personal Linux server setups is a simple Node.js application I wrote called [smtp-pushover](https://github.com/mattbun/smtp-pushover). It's an [SMTP](https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) (email sending) server that forwards any email it receives to [Pushover](https://pushover.net/).

I recently rewrote it in Go and published the new version as [smtn](https://github.com/mattbun/smtn). It supports other notification services now!

<!--more-->

## What do I use this for?

I primarily use this for getting smartd, ZED, apcupsd, etc. messages to my phone in a format I'll actually see.

It also works for quickly sending notifications from the command line since Linux distros tend to include some sort of tool for sending email via SMTP. I have a script called `notify` that's basically just this:

```shell
#!/bin/bash

# Usage: `notify "title" "body"`
echo -e "Subject:$1\n\n$2" | msmtp --from notify@localhost --host localhost whatever@localhost
```

## Why did I rewrite it?

Mostly because I've been writing in Go lately and I felt like I've learned enough since smtp-pushover to do a better job with it. Go also feels like a better fit for this sort of tool.

But I also made a few improvements...

### New features

* **Support for other push notification services... including webhooks!** I think I could link this to [Node-RED](https://nodered.org/) to do all sorts of stuff, like turning on/off lights or forwarding to a LLM to summarize the message.
* **The new webhook support also allowed me to write an e2e/integration test!** And it runs in CI! I have a test that starts a web server, starts smtn configured to send a webhook to the web server, and then verifies that the webhook is called when a message is sent to smtn.

## Other thoughts

### I really like urfave/cli

smtn uses [urfave/cli](https://github.com/urfave/cli) and I've really enjoyed it. It made it easy to make matching command line arguments and environment variable options.

### Naming is hard

When I first started working on this, I called it "smtprrr" like the combination of SMTP and the shoutrrr module that it uses for notifications. But that never really sat well with me.

* It's not really pronounceable ("ess-emm-tee-pee-err"?)
* What if I decided to use a different notification module?
* Is it going to be annoying trying to remember how many r's are at the end?

I ended up naming it "smtn". It's kind of an acronym for "**S**imple **M**ail **t**o **N**otification" and I pronounce it like "smitten". I also wanted to keep it short and one word to resemble Go's module naming conventions.

### A SMTP server? An SMTP server?

Which one of these is correct?

* "A SMTP server"
* "An SMTP server"

Should the _a_/_an_ match the expanded "Simple Mail Transfer Protocol" or should it match how you'd pronounce the letters in "SMTP"?.

TIL the difference between an acronym and an initialism:

* SMTP is an _initialism_ - each letter is pronounced separately, like "LGBT" (does anyone pronounce SMTP as "smittip"?)
* smtn is an _acronym_ - it's pronounced like a regular word, like "NASA"

For initialisms, the _a_ is supposed to match the pronuncation of the first letter. So "_an_ SMTP server" is the correct answer here.

With smtp-pushover, I sneakily avoided confusion by describing it as 

> A _simple_ SMTP server that forwards emails to Pushover

smtn confidently uses the ~wrong~ correct article since [v0.1.2](https://github.com/mattbun/smtn/releases/tag/v0.1.2):

> smtn is an SMTP server that forwards messages to one or more notification services
