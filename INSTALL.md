# Kontalk server install and configuration

Easily installing Kontalk services for development and/or testing
purposes.

Production installs may require additional tweaking, different/better
SSL and GPG configurations and safer database credentials.

**Run all the commands as root**

## Installing kontalk server package

Add the repo to your sources:

    echo deb http://apt.kontalk.rbel.co/debian/wheezy/ ./ \ 
         > /etc/apt/sources.list.d/kontalk.list
    wget http://rubiojr.rbel.co/rubiojr.asc -O - | apt-key add -
    apt-get update

Install the package:

    DEBIAN_FRONTEND=noninteractive apt-get install -y kontalk

DEBIAN_FRONTEND=noninteractive is used here so that mysql-server package accepts defaults and
does not ask you for the root password (defaults to blank).

## Database configuration

The default configurations have been tweaked for minimal fuss so users do not face issues when
configuring Kontalk servers for the first time.

We need to create a new database for the server and create the initial schema:

```
 mysql -u root -e 'create database kontalk'
 mysql -u root kontalk < /opt/kontalk/xmppserver/docs/schema.sql
```

* DB access with root, no password (Debian defaults for MySQL server).

MySQL debian server install do not listen to the world by default so this should be good
enough for testing purposes.

* c2s and resolver database configuration by default is:

```json
// database connection
"database": {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "",
    "dbname": "kontalk",
    "dbmodule": "oursql"
}
```

You can tweak defaults editing config files found in **/etc/kontalk**.

## GnuPG related configuration

We need to generate a new key pair for the Kontalk services so they can encrypt data.
To help the users not very familiar with the process a default gnupg configuration 
is available at /etc/kontalk/gnupg.conf. 
We can run gpg in batch mode to automatically generate the keys for the new users.

Now let's generate a new GnuPG key for the Kontalk server:

    export GNUPGHOME=/etc/kontalk/gnupg 
    gpg --gen-key --batch /etc/kontalk/gnupg.conf
    # Export secret/public keys
    gpg --export -a kontalk > /etc/kontalk/gnupg/server-pgp.crt
    gpg --export-secret-key -a kontalk > /etc/kontalk/gnupg/server-pgp.key


**Important:** if you are running this in a VM you may need to generate a lot 
of entropy for the gpg command to succeed. There are a couple of good ways 
of doing it:

* Install haveged:

    apt-get install haveged 

  See http://pthree.org/2012/09/14/haveged-a-true-random-number-generator

* Install and run rngd:

    apt-get install rng-tools
    /usr/sbin/rngd -r /dev/urandom

## SSL Certificates

The default SSL key/cert used by Kontalk come from the ssl-cert Debian 
package and it is installed as a dependency of the kontalk package if not 
present.

This should be good enough for testing.

## Starting the services

Review Kontalk configuration files in /etc/kontalk making sure the fit your 
needs. In particular, you will need to change the key fingerprint, 
network and host values values among other things.

Services currently available (with init script):

```
kontalk-router
kontalk-resolver
kontalk-c2s
```

## Kontalk FS layout

After installing the kontalk package you'll be able to find the 
following directories and files:

/opt/kontalk: xmppserver plus python deps installed here

/etc/kontalk: services and gnupg configuration

/var/run/kontalk: services pid files

/var/log/kontalk: services log files

/etc/init.d/kontalk-*: init scripts
