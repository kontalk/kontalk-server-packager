# kontalk-packager

Vagrant project to build [Kontalk](http://kontalk.net) server Debian packages.

Currently builds packages for Debian 7.0 (Wheezy), amd64.

More distributions and package formats will be supported in the future.

## Requirements

Git, [Vagrant](http://vagrantup.com) >= 1.1 and [VirtualBox](https://www.virtualbox.org/) installed.

## Building the kontalk package

Clone this repository:

```
git clone https://github.com/rubiojr/kontalk-packager
cd kontalk-packager
```

Run vagrant to build the package:

    vagrant up

This will take some time.

The resulting amd64 binary package will be available in
debian/wheezy/amd64 after that.

## Project layout

**Kontalk configuration templates**

Kontalk server services configuration templates bundled with the package.

```
router.conf
resolver.conf
c2s.conf
```

**Init scripts**

Init scripts installed for router, resolver and c2s services.

```
kontalk-router
kontalk-resolver
kontalk-c2s
```

**Provisioning scripts**

provision.sh is the shell script that does all the heavy lifting when building the
kontalk packages inside the VM.

**GnuPG configuration**

GnuPG config used to generate Kontalk server keys easily without

## Generated package layout

The generated package is a 'fat' binary package. It means that it has all the deps
that the Kontalk server needs to work built-in. 

There are also some additional dependencies
pulled from Debian repos like mysql-server, python, etc, not bundled since the available versions
in the Debian repos are good and we don't need to bundle them.

 
