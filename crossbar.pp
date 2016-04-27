class crossbar ($user = "crossbar") {
  include crossbar_repo

  user { $user:
    ensure     => 'present',
    home       => "/home/${user}",
    shell      => '/bin/bash',
    managehome => 'true',
  }

  Class['crossbar_repo'] ->
  package { 'crossbar': ensure => installed }

  file { "/lib/systemd/system/crossbar.service":
    content => template("foo/crossbar.service.erb"),
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
    command     => "/opt/crossbar/bin/crossbar init --cbdir /home/${user}/.crossbar",
    onlyif      => "test -d /home/${user}/.crossbar",
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