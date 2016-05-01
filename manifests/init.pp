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
class crossbar ($user = "crossbar") {
  include crossbar::repo

  user { $user:
    ensure     => 'present',
    home       => "/home/${user}",
    shell      => '/bin/bash',
    managehome => true,
  }

  Class['crossbar::repo'] ->
  package { 'crossbar': ensure => installed }

  file { "/lib/systemd/system/crossbar.service":
    content => template("crossbar/crossbar.service.erb"),
    ensure  => file,
    require => User[$user],
    notify  => Service["crossbar"]
  }

  file { "/home/${user}/.crossbar/":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => User[$user]
  }

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

  service { "crossbar":
    enable  => true,
    ensure  => running,
    require => Exec["init_crossbar"]
  }

}
