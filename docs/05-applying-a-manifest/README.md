# Apply a manifest

Now we'll set some config on the Cisco IOS device using a Puppet manifest. In this example, we'll create a new NTP server on the switch.

1. Create a manifest file called `manifest.pp` with the following data - replace the IP address to something sensible if desired!

```
ntp_server { '1.1.1.1':
  ensure           => 'present',
  key              => 94,
  prefer           => true,
}
```

2. Apply the manifest using the `bolt apply` command:

`bolt apply manifest.pp -n cisco_ios`

This command uses the manifest to add the NTP servers listed above. You should see output similar to:

```
> bolt bolt apply manifest.pp -n cisco_ios
Starting: install puppet and gather facts on 1.1.1.1
Finished: install puppet and gather facts with 0 failures in 3.22 sec
Starting: apply catalog on 1.1.1.1
Finished: apply catalog with 0 failures in 8.06 sec
Finished on 1.1.1.1:
  changed: 1, failed: 0, unchanged: 0 skipped: 0, noop: 0
Successful on 1 node: 1.1.1.1
Ran on 1 node
```

3. To check that this worked we'll use the cli_command task to get the NTP servers returned. Run the command `bolt task run cisco_ios::cli_command --nodes cisco_ios --params '{"command":"show running-config | include ntp server","raw":true}'` and you should see the newly added NTP server available.

You have just used Bolt and a module to add an NTP Server to your switch.

4. Lastly, if you want check what that manifest is going to do before running it full apply mode, you can the simulation mode `noop` - this highlights the idempotent capabilities of Puppet. To test with `noop`, update the previous manifest and set the ensure property of the address range as `absent` and run the following command: 

`bolt apply manifest.pp -n cisco_ios --noop`. 

Check the output and notice that a corrective change was run in `noop` mode — this means that the NTP server would have been removed if you had run the command without `noop`. If you want to see a much more verbose output include the `--debug` flag.

If you do want to remove the newly created address range, run the same command without `noop` mode: 

`bolt apply manifest.pp -n cisco_ios`

# Next steps

Next we'll run a simple plan to do some troubleshooting.

[Running a plan](./../06-running-a-plan/README.md)
