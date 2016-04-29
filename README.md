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

This module ships a fresh Crossbar.io WAMP Router on your CentOS 7 system
A Systemd service is provided to manage crossbar application

## Setup


### Setup Requirements **OPTIONAL**

* CentOS 7

### Beginning with crossbar

```
include ::crossbar

```

## Usage

```
systemctl start crossbar
```
## Reference

http://crossbar.io/docs/Installation-on-CentOS/

## Limitations

Only support config.json ex novo for now
## Development


