# About Crossword Delivery

A service to grab the New York Times crossword puzzle (via a paid crossword account), print it, and get it mailed to an address.

Created as a Christmas present for Hayley Brooks.

# Deployment and Configuration

Clone this repository on a remote server:
```
git clone https://github.com/gregsherrid/crossword_delivery.git
cd crossword_delivery
```

Make a copy of the example configuration YML file as `private_config.yml` and edit it using a CL text editor:
```
cp ~/config/example-private-config.yml ~/config/private-config.yml
emacs ~/config/private-config.yml
```

You'll need to enter in your To and From addresses, as well as Lob API keys and your NYTimes Cookie.

# Scheduling

Update the 

```
whenever --update-crontab
```

# Email Receipts

This be configured to deliver a receipt by email every time a crossword packet delivery is scheduled. 

Sign up for a [Mailgun account](https://www.mailgun.com), which has a free pricing tier which only delivers mail to verified emails. That's all we'll need: sign up for an account and add your email as a verified email. You can add your own domain to Mailgun but you can also just send under their sandbox domain. Add this email address, your Mailgun API key, and your Mailgun domain to `private-config.yml`.