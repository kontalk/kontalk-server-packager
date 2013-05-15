#!/usr/bin/env bash

SERVER_VERSION=0.0.1
PKG_NAME=kontalk
TARGET_DIR=/opt/$PKG_NAME
SERVER_DIR=$TARGET_DIR/xmppserver
DEBIAN_VERSION=git`date +%Y%m%d%H%M`
USER=kontalk
CFG_DIR=/etc/kontalk
LOG_DIR=/var/log/kontalk
INIT_SCRIPTS_DIR=$SERVER_DIR/init-scripts
CODENAME=`lsb_release -c|awk '{print $2}'`
PKG_ARCH=`dpkg-architecture -qDEB_BUILD_ARCH`

export DEBIAN_FRONTEND=noninteractive 

# Install requirements
sudo apt-get update
sudo apt-get install -y git python-virtualenv python-all-dev libmysqlclient-dev build-essential libgpgme11-dev libgnutls-dev vim

# Get kontalk xmppserver source code
sudo mkdir -p $TARGET_DIR
sudo git clone https://code.google.com/p/kontalk.xmppserver/ $SERVER_DIR
sudo mkdir -p $SERVER_DIR/etc
sudo cp /vagrant/*.conf $SERVER_DIR/etc/

# Install kontalk xmppserver python deps
sudo virtualenv --no-site-packages $TARGET_DIR/python
sudo $TARGET_DIR/python/bin/pip install pip --upgrade
sudo $TARGET_DIR/python/bin/pip install oursql Twisted demjson wokkel pyOpenSSL pygpgme
sudo $TARGET_DIR/python/bin/pip install -e git+https://git.gitorious.org/pygnutls/pygnutls.git#egg=python-gnutls

#
# Debian package post install script
#
cat > post-install.sh << EOH
#!/usr/bin/env bash
# post-install

useradd --system $USER --shell /bin/bash --home /opt/$PKG_NAME/ 

mkdir -p $CFG_DIR/gnupg
chown $USER:$USER $CFG_DIR/gnupg
chmod 700 $CFG_DIR/gnupg
mkdir -p /var/run/$PKG_NAME
mkdir -p $LOG_DIR && chown kontalk $LOG_DIR

chown $USER /var/run/$PKG_NAME
cp $INIT_SCRIPTS_DIR/kontalk-router /etc/init.d/
cp $INIT_SCRIPTS_DIR/kontalk-resolver /etc/init.d/
cp $INIT_SCRIPTS_DIR/kontalk-c2s /etc/init.d/
cp $SERVER_DIR/etc/*.conf $CFG_DIR/
chown kontalk:kontalk -R $TARGET_DIR
EOH

#
# Copy kontalk init scripts to the kontalk source directory
#  so they are bundled with the package
#
mkdir -p $INIT_SCRIPTS_DIR
cp /vagrant/router.init $INIT_SCRIPTS_DIR/kontalk-router
cp /vagrant/resolver.init $INIT_SCRIPTS_DIR/kontalk-resolver
cp /vagrant/c2s.init $INIT_SCRIPTS_DIR/kontalk-c2s

#
# Package it using fpm: https://github.com/jordansissel/fpm
# Creates a fat binary package bundling kontalk plus deps
#
sudo gem install --no-ri --no-rdoc fpm
fpm --after-install post-install.sh --iteration $DEBIAN_VERSION -d python -d ruby -d ssl-cert -d mysql-server -s dir -t deb -n $PKG_NAME -a native --version $SERVER_VERSION $TARGET_DIR
mv *.deb /vagrant/debian/$CODENAME/$PKG_ARCH
