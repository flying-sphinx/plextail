# Plextail

Plextail tails a group of files, and passes them through to Heroku's Logplex.

## Installation

It's a gem, so use it like you would any other gem - probably by putting it in your Gemfile:

    gem 'plextail', '0.0.1'

## Usage

Track some log files, and make sure both the Logplex token and process id are set:

    Plextail.track("path", "to", "*.log") do |line|
      line.token      = '...'
      line.process_id = 'daemon.1'
    end

The line will be sent through to Heroku using the provided details. If you want to change the server, use the LOGPLEX_URI environment variable – otherwise, the default is https://east.logplex.io.

You can customise the following attributes on the yielded line object:

* `token` – the logplex token,
* `version` – the logplex version, which defaults to `<134>1`,
* `timestamp` – the timestamp for the line, which defaults to the current time, in the following format: `%Y-%m-%dT%H:%M:%S.ms+00:00`,
* `hostname` – host name of the log source (doesn't seem to impact Heroku's output), defaults to your computer's host name,
* `process_id` – the source of the log file (e.g. web.1)
* `message_id` – defaults to `- -`, and
* `message` – the remainder/core of the log line, which defaults to the entire raw line from the file.

The line also has two attributes available to help any custom logic you may involve in the processing: `file` (the file that has a new line appended) and `raw` (the raw line that has appeared in the file).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Copyright (c) 2013, Plextail is developed and maintained by Pat Allan, and is released under the open MIT Licence.
