= twitterscrobble

* http://twitterscrobble.rubyforge.org

== DESCRIPTION:

This application posts recently played tracks from last.fm to Twitter.

== SYNOPSIS:

    twitterscrobble [options]

For help use:

    twitterscrobble.rb -h

The following command reads all most recently played tracks from a last.fm account
and posts them to Twitter. All settings are read from the preferences file.

    twitterscrobble.rb

The following command prints the status line of recent tracks to stdout (not posting to Twitter), assuming a history value of 0 and not saving state.

    twitterscrobble.rb --no-post --history 0 --no-save

The following posts all recent tracks and store user names and password in the preferences file. This is suitable as the initial invocation, as it creates the preferences file for later invocation without the user detail.

    twitterscrobble.rb --scrobbler-user foo --twitter-user FooBar --twitter-password bar

== REQUIREMENTS:

* twitter
* scrobbler
* shorturl

== INSTALL:

* sudo gem install twitterscrobble

This script is probably run best from CRON:

$> crontab -l
# m h  dom mon dow   command
* * * * * /home/nerab/projects/atom2nntp/workspace/twitterscrobble/bin/twitterscrobble --loglevel warn --logfile /home/nerab/.twitterscrobble/twitterscrobble.log 

The entry to the user's crontab can be made with

	crontab -e

This will invoke the default editor for making changes to the user's crontab.

= Author

Nicolas E. Rabenau, nerab@gmx.at

== LICENSE:

(The MIT License)

Copyright (c) 2008 Nicholas E. Rabenau

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
