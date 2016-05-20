# Class: crossbar
#===========================
#
# Crossbar.io WAMP Router Puppet module
#
# Parameters
#----------
#
# * `user`
# A system user that init and starts Crossbar through Systemd
# Default is: crossbar
# * `log_level`
# Crossbar service log level, select one from: none|critical|error|warn|info|debug|trace
# Default is: none
# * `config`
# A user created config.json to be provided as file source puppet:// or file:///
# Default is: undef
#
#
# Examples
#--------
#
# @example
#    class { 'crossbar':
#      user => 'centos',
#    }
#
# Authors
#-------
#
# Natale Vinto <ebballon@gmail.com>
#
# Copyright
#---------
#
# Copyright 2016 Natale Vinto.
#
class crossbar ($user = "crossbar", $log_level = 'none', $config = undef) {
  include crossbar::repo

  case $log_level {
    /(none|critical|error|warn|info|debug|trace)/ : { notice("Deploying Crossbar with log level ${1}") }
    default : { fail("Log level not valid, choose one from: none|critical|error|warn|info|debug|trace") }
  }

  user { $user:
    ensure     => 'present',
    home       => "/home/${user}",
    shell      => '/bin/bash',
    managehome => true,
  }

  Class['crossbar::repo'] ->
  package { 'crossbar': ensure => installed }

  if $::operatingsystem == "Ubuntu" {
    file { "/etc/init/crossbar.conf":
      content => template("crossbar/crossbar.conf.erb"),
      ensure  => file,
      require => User[$user],
      notify  => Service["crossbar"]
    }
  } else {
    file { "/lib/systemd/system/crossbar.service":
      content => template("crossbar/crossbar.service.erb"),
      ensure  => file,
      require => User[$user],
      notify  => Service["crossbar"]
    }

  }

  file { "/home/${user}/.crossbar/":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => User[$user]
  }

  if $config == undef {
    exec { 'init_crossbar':
      command     => "/opt/crossbar/bin/crossbar init",
      onlyif      => "/usr/bin/test -d /home/${user}/.crossbar",
      user        => $user,
      cwd         => "/home/${user}/",
      logoutput   => true,
      refreshonly => true,
      require     => Package['crossbar'],
      subscribe   => File["/home/${user}/.crossbar/"]
    }
  } else {
    if $config =~ /^(file:|puppet:)/ {
      file { "/home/${user}/.crossbar/config.json":
        ensure  => file,
        owner   => $user,
        group   => $user,
        require => File["/home/${user}/.crossbar/"]
      }

      exec { 'update_crossbar':
        command     => "/opt/crossbar/bin/crossbar update --cbdir=/home/${user}/.crossbar ",
        onlyif      => "/usr/bin/test -d /home/${user}/.crossbar",
        user        => $user,
        cwd         => "/home/${user}/",
        logoutput   => true,
        refreshonly => true,
        require     => Package['crossbar'],
        subscribe   => File["/home/${user}/.crossbar/config.json"]
      }
    } else {
      fail("config.json location should be file:/// or puppet://")
    }
  }

  service { "crossbar":
    enable  => true,
    ensure  => running,
    require => Exec["init_crossbar"]
  }

}
