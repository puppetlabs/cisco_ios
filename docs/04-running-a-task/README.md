# Run a task

Use Bolt to connect to the device and run a task. The module comes with some tasks already available. We'll run the `cli_command` task which allows an aribtrary command to be run at the command line of the device and a response returned.

For this example, we'll return the list of ntp_servers that are configured on the device. At the Cisco IOS device's CLI this list can be returned by issuing a simple `show command` - common practice for network administrators. In this case, the command we want to run on the device is: `show running-config | include ntp server`.

1. We'll use the `cisco_ios::cli_command` task to execute a command at the command line of the device and have the response returned in the terminal. Run:

`bolt task run cisco_ios::cli_command --nodes cisco_ios command='show running-config | include ntp' raw=true`

> Note that `--nodes` represents the nodes, `cisco_ios` is the alias you set in the `inventory.yaml` file, and the rest of the command represents the parameters to be sent to the device, this case including the command to be executed at the device's CLI (`show running-config | include ntp`) and whether or not the response should be in raw format or wrapped in JSON, which may be useful if parsing the response as part of a script or bolt plan.

2. You should receive output similar to what's displayed below. In this case bolt has logged into the device, issued the command against the CLI and returned the response, as shown below - this is the same response that would be received if the command was issued from the command line.
```
> bolt task run cisco_ios::cli_command --nodes cisco_ios command='show running-config | include ntp' raw=true
Started on 1.1.1.1...
Finished on 1.1.1.1:
  show running-config | include ntp server
  ntp server 192.168.10.200 prefer
  ntp server 192.168.10.201
  ntp server 1.2.3.4 key 94 prefer
  ntp server 192.168.10.1 version 2 prefer
  ntp server 5.6.7.8 key 55 prefer
  ios-switch#
  {
  }
Successful on 1 node: 1.1.1.1
Ran on 1 node in 3.67 seconds
```

3. Run some other commands. A common use case for running commands on a device is to troubleshoot network issues. This is possible using the above `cli_command` task, for example to ping an IP address from the device, run the command as follows: `bolt task run cisco_ios::cli_command --nodes cisco_ios command="ping 8.8.8.8" raw=true` and you should receive output such as that below:
```
> bolt task run cisco_ios::cli_command --nodes cisco_ios command="ping 8.8.8.8" raw=true
Started on 1.1.1.1...
Finished on 1.1.1.1:
  ping 8.8.8.8
  Type escape sequence to abort.
  Sending 5, 100-byte ICMP Echos to 8.8.8.8, timeout is 2 seconds:
  .....
  Success rate is 0 percent (0/5)
  ios-switch#
  {
  }
Successful on 1 node: 1.1.1.1
Ran on 1 node in 18.31 seconds
```

As you can see, with the CLI Command task it is possible to execute commands against a device and get the response returned. It is possible to include such tasks in a [bolt plan](https://puppet.com/docs/bolt/latest/writing_plans.html) if you want to chain together multiple commands as part of a standard troubleshooting script.

# Next steps

Next we will show how to apply a manifest to set some config on the switch.

[Applying a manifest](./../05-applying-a-manifest/README.md)
