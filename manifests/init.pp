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
class crossbar ($user = "crossbar",
		$service_enable = true,
		$service_status = running,
		$service_name = "crossbar",
		$log_level = 'none',
		$config_json = undef
		) {
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
    file { "/etc/init/${service_name}.conf":
      content => template("crossbar/crossbar.conf.erb"),
      ensure  => file,
      require => User[$user],
      notify  => Service[$service_name]
    }
  } else {
    file { "/lib/systemd/system/${service_name}.service":
      content => template("crossbar/crossbar.service.erb"),
      ensure  => file,
      require => User[$user],
      notify  => Service[$service_name]
    }

  }

  file { "/home/${user}/.crossbar/":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => User[$user]
  }

  if $config_json == undef {
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
    if $config_json =~ /^(file:|puppet:)/ {
      file { "/home/${user}/.crossbar/config.json":
        ensure  => file,
        owner   => $user,
        group   => $user,
        source  => $config_json,
        require => File["/home/${user}/.crossbar/"]
      }

      exec { 'upgrade_crossbar':
        command     => "/opt/crossbar/bin/crossbar upgrade --cbdir=/home/${user}/.crossbar ",
        onlyif      => "/usr/bin/test -d /home/${user}/.crossbar",
        user        => $user,
        cwd         => "/home/${user}/",
        logoutput   => true,
        refreshonly => true,
	notify      => Service[$service_name],
        require     => Package['crossbar'],
        subscribe   => File["/home/${user}/.crossbar/config.json"]
      }
    } else {
      fail("config.json location should be file:/// or puppet://")
    }
  }

  service { $service_name:
    enable  => $service_enable,
    ensure  => $service_status,
  }



}
