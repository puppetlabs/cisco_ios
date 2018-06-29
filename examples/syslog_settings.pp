syslog_settings { 'default':
  enable           => false,
  facility         => 'local5',
  monitor          => 6,
  console          => 6,
  source_interface => ['Loopback24'],
}
