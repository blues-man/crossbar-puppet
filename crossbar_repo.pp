class crossbar_repo {
  $osver = split($::operatingsystemrelease, '[.]')

  if $::operatingsystem == "CentOS" {
    case $osver[0] {
      '7'     : { $baseurl = 'http://package.crossbar.io/centos/7/' }
      default : { fail('Unsupported version of CentOS') }
    }

    yumrepo { 'crossbar':
      baseurl  => $baseurl,
      descr    => 'CentOS $releasever - Crossbar',
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-crossbar',
      priority => 30,
    }

    file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-crossbar":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "puppet:///modules/foo/rpm-gpg/RPM-GPG-KEY-crossbar",
    }

    exec { "import-crossbar":
      path      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command   => "rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-crossbar",
      unless    => "rpm -q gpg-pubkey-$(echo $(gpg --throw-keyids --keyid-format short < /etc/pki/rpm-gpg/RPM-GPG-KEY-crossbar) | cut --characters=11-18 | tr '[A-Z]' '[a-z]')",
      require   => [File["/etc/pki/rpm-gpg/RPM-GPG-KEY-crossbar"], Yumrepo["crossbar"]],
      logoutput => 'on_failure',
    }

  }

}