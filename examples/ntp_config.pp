ntp_config { 'default':
  authenticate => true,
  source_interface => 'Vlan42',
  trusted_key => [12,24,48,96],
}
