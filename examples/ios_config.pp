# Simple examples
ios_config { 'bill':
  command          => 'ip domain-name bill',
  idempotent_regex => 'ip domain-name bill'
}

# Example including regex options
ios_config { 'jimmy':
  command                  => 'ip domain-name jimmy',
  idempotent_regex         => 'ip domain-name JIMMY',
  idempotent_regex_options => ['ignorecase'],
}

# Advanced example
ios_config { 'test-acl':
    command          => "
    no ip access-list extended test-acl
    ip access-list extended test-acl
      permit tcp 192.168.10.0 0.0.0.255 any eq 22 log
      permit udp 192.168.10.0 0.0.0.255 any
    ",
    # This regex has a negative lookahead at the end to ensure we do not match any addtional lines
    idempotent_regex => 'ip access-list extended test-acl\\n permit tcp 192.168.10.0 0.0.0.255 any eq 22 log\\n permit udp 192.168.10.0 0.0.0.255 any\\n(?!\s+(deny|permit))',
}