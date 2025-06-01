
# OpenBSD 6.0

### Packages

Set temporary package path:

    export PKG_PATH=ftp://ftp.eu.openbsd.org/pub/OpenBSD/6.0/packages/amd64/

Add packages:

    pkg_add zsh zap screen vim ruby git postgresql-server redis nginx node ImageMagick cairo ffmpeg libv8 ruby23-therubyracer libxslt libxml2

For GIF to MP4 conversion, fixes `Cocaine::CommandNotFoundError`:

    git clone https://github.com/danielgtaylor/qtfaststart
    python setup.py install

### Users

Assumes user `dev` was created during the OpenBSD installation.

Set shells to [http://zsh.org/](http://zsh.org/):

    chsh -s /usr/local/bin/zsh root
    chsh -s /usr/local/bin/zsh dev

Add to `wheel` group:

    usermod -G wheel dev

Add Brgen account:

    user add -m -d /home/www/brgen/ -g wheel -s /usr/local/bin/zsh brgen

### System configuration

Clone Brgen:

    git clone https://github.com/idiotisk-firmanavn/brgen.git
    mv brgen/* brgen/.* .
    rmdir brgen/

    cd bsd/
    cp -R * /

    chmod +x /etc/rc.d/brgen
    chown -R root:_nsd *

### Domain name server

[http://nlnetlabs.nl/projects/nsd/](http://nlnetlabs.nl/projects/nsd/)

Start the server:

    /etc/rc.d/nsd start

### Email

[http://opensmtpd.org/](http://opensmtpd.org/)

Rebuild email aliases:

    newaliases

### HTTP server

[http://nginx.org/](http://nginx.org/)

Generate SSL key and certificate:

    mkdir /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

Start the server:

    /etc/rc.d/nginx start

### Ruby server

[http://puma.io/](http://puma.io/)

Install system-wide so it can be accessed by [rc.d(8)](http://openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/rc.d.8) init script:

    doas gem install bundler
    doas gem install puma

### Database

[http://postgresql.org/](http://postgresql.org/)

    doas su _postgresql

Initialize PostgreSQL:

    initdb -D /var/postgresql/data/ --no-locale -E UTF8
    exit

Start PostgreSQL:

    doas /etc/rc.d/postgresql start

Enter user:

    doas su _postgresql

Create the database:

    psql template1

    CREATE ROLE <username> SUPERUSER LOGIN PASSWORD 'IeY3ieta';
    \q

# Brgen

See `config/secrets.yml` and `.apikeys` for passwords and API keys.

Make temporary directory accessible to Puma:

    chown root:www tmp/

Install Brgen's dependencies, and do it as root to avoid permission issues.

Nokogiri requires pre-installed OpenBSD packages such as `libxslt` and `libxml2`:

    doas gem install nokogiri -- --use-system-libraries

    doas bundle install

Set up the database:

    bundle exec rake db:schema:load RAILS_ENV=production

    Or:

    bundle exec rake db:create RAILS_ENV=production
    bundle exec rake db:migrate RAILS_ENV=production

    Load dummy posts:

    bundle exec rake db:seed RAILS_ENV=production

Do all of the above including `rake db:drop`:

    bundle exec rake db:reset RAILS_ENV=production

Export translations:

    bundle exec rake i18n:js:setup
    bundle exec rake i18n:js:export

Precompile assets:

    bundle exec rake assets:precompile RAILS_ENV=production

Export `config/schedule.rb` to `cron(8)`:

    whenever -i

Start the server:

    /etc/rc.d/brgen start

Aliases `brgen_start` and `brgen_stop` are set in `.zshrc`.

# Scrapers

[https://github.com/bebraw/spyder](https://github.com/bebraw/spyder)

    sudo npm install spyder -g

    cd scrapers
    npm install

# Photoedit

    cd photoedit
    npm install

# Twitter streaming

[https://github.com/tweetstream/tweetstream](https://github.com/tweetstream/tweetstream)

Edit list of followers in `app/workers/twitter_streamer.rb`. Get their IDs using [Get Twitter ID](http://gettwitterid.com/).

# CPU limiting

[https://github.com/opsengine/cpulimit](https://github.com/opsengine/cpulimit)

    mv /usr/local/bin/convert /usr/local/bin/convert_raw
    echo '/usr/local/bin/cpulimit --limit 20 /usr/local/bin/convert_raw "$@"' > /usr/local/bin/convert
    chmod +x /usr/local/bin/convert

    mv /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg_raw
    echo '/usr/local/bin/cpulimit --limit 20 /usr/local/bin/ffmpeg_raw "$@"' > /usr/local/bin/ffmpeg
    chmod +x /usr/local/bin/ffmpeg

    mv /usr/local/bin/spyder /usr/local/bin/spyder_raw
    echo '/usr/local/bin/cpulimit --limit 20 /usr/local/bin/spyder_raw "$@"' > /usr/local/bin/spyder
    chmod +x /usr/local/bin/spyder

# Model annotation

[https://github.com/ctran/annotate_models](https://github.com/ctran/annotate_models)

    annotate

# Development

[https://github.com/guard/guard-livereload](https://github.com/guard/guard-livereload)

    bundle exec guard

# Testing

    rake db:test:prepare
    rake test

