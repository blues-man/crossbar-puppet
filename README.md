# Crossbar Puppet module

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with crossbar](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with crossbar](#beginning-with-crossbar)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module ships a fresh [Crossbar.io](http://crossbar.io/) WAMP Router on your systems

A Systemd service is provided to manage crossbar application, and also Upstart support
for Ubuntu 14.04 compatibility

## Setup


### Setup requirements

* CentOS 7
* RHEL 7
* Ubuntu 14.04

### Beginning with crossbar

By default Crossbar is installed for crossbar system user with debug level set to 'none'

```
include ::crossbar

```

## Usage

You can assign your own Crossbar system user passing it to the class constructor, with
your preferred log level:

```
class { 'crossbar': 
    user      => 'centos',
    log_level => 'debug'
}
```

You can also provide your custom config.json with your preferred options for Crossbar (port, tls, etc):

```
class { 'crossbar': 
    config_json  => "file:///tmp/config.json",
}
```

```
class { 'crossbar': 
    config_json  => "puppet://modules/foo/config.json",
}
```

Crossbar service by default is enabled and running, but you can control it as you wish:

```
class { 'crossbar': 
    service_enable  => false,
    service_status  => stopped
}
```

Manage then crossbar as systemd daemon

```
systemctl start|status|restart|stop crossbar
```

Manage crossbar with upstart

```
service crossbar start|status|restart|stop
```

## Reference

http://crossbar.io/docs/Installation-on-CentOS/

http://crossbar.io/docs/Installation-on-Ubuntu/

## Limitations

Only support config.json ex novo for now

## Development

https://github.com/blues-man/crossbar-puppet
