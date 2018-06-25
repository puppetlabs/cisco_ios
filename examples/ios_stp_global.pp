ios_stp_global { 'default':
  bridge_assurance  => true,
  loopguard         => true,
  mode              => 'rapid-pvst',
  mst_forward_time  => 13,
  mst_hello_time    => 4,
  mst_inst_vlan_map => [
    [2, '1-41, 44-65'],
    [15, '42-43']],
  mst_max_age       => 19,
  mst_max_hops      => 42,
  mst_name          => 'potato',
  mst_priority      => [
    ['0-4', 24576],
    ['7', 8192]],
  mst_revision      => 42,
  pathcost          => 'long',
  vlan_forward_time => [
    ['2', 6],
    ['3-6', 24]],
  vlan_hello_time   => [
    ['200-2000', 7]],
  vlan_max_age      => [
    ['1', 11],
    ['42-44', 35]],
  vlan_priority     => [
    ['1', 40960]],
}
