# Class: crossbar::repo
#===========================
#
# Install Crossbar as RPM or DEB package for supported OS
class crossbar::repo {
  $osver = split($::operatingsystemrelease, '[.]')

  if $::operatingsystem == "CentOS" or $::operatingsystem == "RedHat" {
    case $osver[0] {
      '7'     : { $baseurl = 'http://package.crossbar.io/centos/7/' }
      default : { fail('Unsupported version of CentOS or RHEL') }
    }

    yumrepo { 'crossbar':
      baseurl  => $baseurl,
      descr    => 'CentOS $releasever - Crossbar',
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => "http://pool.sks-keyservers.net/pks/lookup?op=get&search=0x5FC6281FD58C6920",
      priority => 30,
    }
  } elsif $::operatingsystem == "Ubuntu" {
    case $::operatingsystemrelease {
      '14.04' : { $release = 'trusty' }
      '16.04' : { $release = 'xenial' }
      default : { fail('Unsupported version of Ubuntu') }
    }
    include apt

    apt::source { 'crossbar':
      comment  => 'Crossbar.io official binary packages',
      location => 'http://package.crossbar.io/ubuntu',
      release  => $release,
      repos    => 'main',
      key      => {
        'id'     => '665415B518DA028EFB57E9BF5FC6281FD58C6920',
        'server' => 'hkps.pool.sks-keyservers.net',
      }
    }

  }
}
