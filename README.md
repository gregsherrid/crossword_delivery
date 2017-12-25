# About Crossword Delivery

A service to grab the New York Times crossword puzzle (via a paid crossword account), print it, and get it mailed to an address.

Created as a Christmas present for Hayley Brooks.

# Deployment and Configuration

Clone this repository on a remote server:
```
git clone https://github.com/gregsherrid/crossword_delivery.git
cd crossword_delivery
```

This requires ruby 2.4.1, although it might work in other ruby versions (by removing the `.ruby-version` file).

# Configuration

Make a copy of the example configuration YML file as `private-config.yml` and edit it using a CL text editor:
```
cp config/example-private-config.yml config/private-config.yml
emacs config/private-config.yml
```

### Puzzles per packet

By default, the configuration will allow 7 puzzles to build up before scheduling a delivery. Customize the `min_puzzles_per_packet` value in `private-config.yml` to change this limit. Lower limits will cause puzzles to be delivered more frequently but at a higher cost.

### Addresses

You'll need to enter in your To and From addresses, following the examples in `private-config.yml`. 

### NYTimes Crossword account

Without registering for an account, you can just put any string in this field and you'll be able to grab a small selection of free puzzles off the [New York Times Crossword homepage](https://www.nytimes.com/crosswords). 

When logged into a paid account, look up your browser cookie in the request headers sent on any page and enter it into `private-config.yml`.

### Lob API keys

[Lob](https://lob.com) provides an API for sending letters. They have a "Developer" pricing tier that supports pay-as-you go letter delivery. Sign up for an account and copy your test and live API keys (you'll have to enter a credit card to access the live API key).

At of the [time of this writing](https://lob.com/pricing/letters), each letter costs $0.84 + $0.10 per page (the first page is reserved for the address).

Letters sent using the test API key will never be sent. Letters sent with the live key can be cancelled on Lob's dashboard for a period of 5 minutes.

### Receipts

The service can be configured to deliver a receipt by email every time a crossword packet delivery is scheduled. This is turned off by default, but can be activated by settings the `active` values in `receipts` to true and adding additional information.

[Mailgun account](https://www.mailgun.com) has a free pricing tier which only delivers mail to verified emails. Sign up for an account and add your email as a verified email. You can add your own domain to Mailgun but you can also just send under their sandbox domain. Add this email address, Mailgun API key, and your Mailgun domain to `private-config.yml`.

# Scheduling

Update the crontab on the server by using the following command in the project directory:

```
bundle exec whenever --update-crontab
```

Unless you change the scheduler (`config/schedule.rb`), it will check for new crosswords once every day.