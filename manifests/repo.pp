class repo {
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
      gpgkey   => "http://pool.sks-keyservers.net/pks/lookup?op=get&search=0x5FC6281FD58C6920",
      priority => 30,
    }
  }
}
