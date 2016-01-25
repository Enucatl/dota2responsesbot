package { 'fail2ban':
  ensure => present,
}

class { 'locales': }

package { 'postgresql-server-dev-all':
  ensure => present,
}

package { 'nodejs':
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
  port => 8080
}

ufw::allow { "allow-https":
  port => 443
}

class { 'ssh::server':
  options => {
    'PasswordAuthentication' => 'no',
  },
}

include apt::unattended_upgrades

file { ['/home/dota2responsesbot/dota2responsesbot',
'/home/dota2responsesbot/dota2responsesbot/releases',
'/home/dota2responsesbot/dota2responsesbot/shared']:
  ensure => "directory",
  owner => 'dota2responsesbot',
  group => 'dota2responsesbot'
}

class { 'postgresql::server':
  require => Class['locales'],
}

postgresql::server::db { 'dota2responsesbot_production':
  user => 'dota2responsesbot',
  password => '',
}

exec { "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3":
  provider => shell,
  logoutput => true,
  cwd => "/home/dota2responsesbot",
  user => "dota2responsesbot",
  before => Single_user_rvm::Install["dota2responsesbot"]
  unless => "gpg --list-keys 409B6B1796C275462A1703113804BB82D39DC0E3",
  require => User["dota2responsesbot"],
}

single_user_rvm::install { 'dota2responsesbot': }

single_user_rvm::install_ruby { '2.3.0':
  user => 'dota2responsesbot'
}

exec { "su -l dota2responsesbot -c 'rvm get stable --auto-dotfiles; rvm use --default ruby-2.3.0'":
  path => "/usr/bin:/usr/sbin:/bin:~/.rvm/bin",
  provider => shell,
  logoutput => true,
  cwd => "/home/dota2responsesbot",
  unless => "su -l dota2responsesbot -c 'rvm current' | grep ruby-2.3.0",
  require => Single_user_rvm::Install_ruby['2.3.0'],
}

class { 'nginx': }

nginx::resource::upstream { 'unicorn':
  members => [
    'unix:/tmp/unicorn.dota2responsesbot.sock fail_timeout=0',
  ],
}

nginx::resource::vhost { 'dota2responsesbot':
  ensure => present,
  listen_options => 'deferred',
  client_max_body_size => '20M',
  www_root => '/home/dota2responsesbot/dota2responsesbot/current/public',
  try_files => ['$uri/index.html', '$uri', '@unicorn'],
  vhost_cfg_append => {
    error_page => '500 502 503 504 /500.html',
    keepalive_timeout => 10
  },
}

nginx::resource::location { 'dota2responsesbot-assets-location':
  ensure => present,
  location => "~ ^/assets/",
  vhost => 'dota2responsesbot',
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
  location_custom_cfg => {
    proxy_set_header => {
      'X-Forwarded-For' => '$proxy_add_x_forwarded_for',
      'Host' => '$http_host',
    },
    proxy_redirect => 'off',
    proxy_pass => 'http://unicorn'
  },
}
