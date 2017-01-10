package { 'fail2ban':
  ensure => present,
}

class { 'locales': }

package { 'openssl':
  ensure => present,
  before => Exec['ssl_certificates'],
}

package { 'gnupg2':
  ensure => present,
  before => Exec['import_rvm_key'],
}

package { 'libopus0':
  ensure => present,
}

package { 'libav-tools':
  ensure => present,
}

package { 'build-essential':
  ensure => present,
}

package { 'libgmp-dev':
  ensure => present,
}

package { 'libpq-dev':
  ensure => present,
}

package { 'postgresql-server-dev-all':
  ensure => present,
}

user { 'dota2responsesbot':
  ensure => present,
  password => '$1$D5KK5H7a$OCs4OnweVdEe/ll2ZevPd1',
  shell => '/bin/bash',
  managehome => true,
  before => Class['ssh::server', 'sudo'],
}

ssh_authorized_key { 'home_computer_key':
  ensure => present,
  user => 'dota2responsesbot',
  key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5jD7/p8luC+QyItm21oHZxunN4kjqkrZzieIOaPnPdbIRXFfkwbs4UMd2pch0d5g/CwRS0NN2lPsfYw2oN7Y7xM+x28iOU5Baw8s+K3EsZoiJv5oIewKvS+cOkmWbKCLwPxthB5qLvtLdeSKaEHbXueQCH/sJjZ20EE0DAC5tltZYvhcSoL/2Pi5sGmCboBvOkYvpXUtJuSsDegETJK4off1zysFuE2AWCZ3BSEDjIjvegVtH/5q0ED99jUFY769lZzRbjcmzWVqAmY/Pn8cWWCAeH2lvd9JAVL6dvyYl7kftbvi6SHvoJ56Km1Fn2KQwVT8EviIsG6gNlxrZfYVn',
  type => 'rsa',
}

ssh_authorized_key { 'office_computer_key':
  ensure => present,
  user => 'dota2responsesbot',
  key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDJCbc4Sv6r8NcQSNc8T1dLoYnLDsNO0Kd/AwSIXE6UjF2X/gC1+9bLtIn4wUppLJzr85+2ltDEBl2peROJRuCk8uFVye1ip5Gyz5JLnpeIzUxYIowa780KXgUdbZdlp/P6uNXlbEGqo9xAUHd2sPfGaVRG7zsuRiolzAZTp/FeLtfJLwd7jp09dV08xUj2tHdFicnJNnnJTmx+3YdSPq0VOpXlvYc9xHms+VasVhg/bLl6IfqXxZ1cC0BSUfkQrIIz+QUZP8vNe+VD6wJaq4vGBX49IrRVMqnZIZbplMJKQcZfR/hGzOWRn7dZ/b8ZYykR618yb4FHYTZQCvS89Kuj',
  type => 'rsa',
}

class { 'sudo':
  keep_os_defaults => false,
  defaults_hash => {
    env_reset => true,
    mail_badpass => true,
    secure_path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  },
  confs_hash => {
    'root' => {
      ensure => present,
      content => 'root ALL=(ALL) NOPASSWD: ALL'
    },
    'dota2responsesbot' => {
      ensure => absent,
    },
  },
}

include ufw

ufw::allow { "allow-ssh-from-all":
  port => 22,
}

ufw::allow { "allow-http":
  port => 88
}

ufw::allow { "allow-https":
  port => 443
}

class { 'ssh::server':
  options => {
    'PasswordAuthentication' => 'no',
  },
}

file { ['/home/dota2responsesbot/dota2responsesbot',
'/home/dota2responsesbot/dota2responsesbot/releases',
'/home/dota2responsesbot/dota2responsesbot/shared']:
  ensure => "directory",
  owner => 'dota2responsesbot',
  group => 'dota2responsesbot'
}

class { 'postgresql::server':
  listen_addresses => "",
  require => Class['locales'],
}

postgresql::server::role { 'dota2responsesbot':
  password_hash => 'md58328b143eabb3fc8a2ab7d354bc27ce2',
  createdb => true,
  login => true,
}

exec { "import_rvm_key":
  command => "gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3",
  provider => shell,
  logoutput => true,
  cwd => "/home/dota2responsesbot",
  user => "dota2responsesbot",
  before => Rvm::Ruby["ruby_installation"],
  unless => "gpg2 --list-keys 409B6B1796C275462A1703113804BB82D39DC0E3",
  require => User["dota2responsesbot"],
}

rvm::ruby { 'ruby_installation':
  user => 'dota2responsesbot',
  version => '2.4.0',
}

rvm::gem { 'bundler':
  ruby => Rvm::Ruby['ruby_installation'],
}

class { 'nginx': }

nginx::resource::upstream { 'dota2responsesbotupstream':
  members => [
    'unix:/tmp/unicorn.dota2responsesbot.sock',
  ],
}

nginx::resource::vhost { 'dota2responsesbot':
  ensure => present,
  ssl => true,
  listen_port => 443,
  ssl_port => 443,
  ssl_cert => '/home/dota2responsesbot/dota2responsesbot/ssl/selfsigned.pem',
  ssl_key => '/home/dota2responsesbot/dota2responsesbot/ssl/selfsigned.key',
  listen_options => 'deferred',
  client_max_body_size => '20M',
  www_root => '/home/dota2responsesbot/dota2responsesbot/current/public',
  try_files => ['$uri/index.html', '$uri', '@unicorn'],
  vhost_cfg_append => {
    error_page => '500 502 503 504 /500.html',
    keepalive_timeout => 10,
  },
}

nginx::resource::location { 'dota2responsesbot-assets-location':
  ensure => present,
  location => "~ ^/assets/",
  vhost => 'dota2responsesbot',
  ssl => true,
  ssl_only => true,
  location_custom_cfg => {
    root => '/home/dota2responsesbot/dota2responsesbot/current/public',
    gzip_static => "on",
    expires => "max",
    add_header => "Cache-Control public",
  },
}

nginx::resource::location { 'dota2responsesbot-unicorn-location':
  ensure => present,
  location => "@unicorn",
  vhost => 'dota2responsesbot',
  ssl => true,
  ssl_only => true,
  location_custom_cfg => {
    proxy_set_header => {
      'X-Forwarded-For' => '$proxy_add_x_forwarded_for',
      'Host' => '$http_host',
    },
    proxy_redirect => 'off',
    proxy_pass => 'http://dota2responsesbotupstream'
  },
}

file { '/home/dota2responsesbot/dota2responsesbot/ssl':
  ensure => "directory",
  owner => 'dota2responsesbot',
  group => 'dota2responsesbot',
  before => Exec['ssl_certificates'],
}

exec { 'ssl_certificates':
  command => "openssl req -newkey rsa:2048 -sha256 -nodes -keyout selfsigned.key -x509 -days 365 -out selfsigned.pem -subj '/C=CH/L=Zurich/O=Enucatl/CN=$ipaddress'",
  path => '/usr/bin',
  group => 'dota2responsesbot',
  user => 'dota2responsesbot',
  cwd => '/home/dota2responsesbot/dota2responsesbot/ssl',
  creates => '/home/dota2responsesbot/dota2responsesbot/ssl/selfsigned.pem',
  notify => Nginx::Resource::Vhost['dota2responsesbot']
}
