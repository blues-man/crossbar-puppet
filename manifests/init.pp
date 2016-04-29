# Class: crossbar
# ===========================
#
# Full description of class crossbar here.
#
# Parameters
# ----------
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'crossbar':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class crossbar ($user = "crossbar") {
  include crossbar::repo

  user { $user:
    ensure     => 'present',
    home       => "/home/${user}",
    shell      => '/bin/bash',
    managehome => 'true',
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
    status  => running,
    require => Exec["init_crossbar"]
  }

}
