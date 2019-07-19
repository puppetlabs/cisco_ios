# Run a plan

Finally, we'll run a plan to perform some basic troubleshooting. This plan can be easily amended to meet your own needs. We're going to execute some commands using the `cli_command` task, parse the response to match for specific strings that might indicate problems, and then output a message to the console. This plan can be amended to meet your needs to include your typical troubleshooting commands. It can also be executed against multiple hosts.

In this example we're going to assume that we're having some network issues and we've narrowed it down to what we believe is a poorly perform device. We'll run the following commands as part of a plan:
* Ping an IP address, checking connectivity from point A to B.
* Check if the device is using its own clock, to check if NTP settings appear to be OK.
* Check if the fan and temperature are within normal bounds.
* Check if any network interfaces are showing errors.

Of course, this plan can be amended to include any specific commands you'd like, such as checking the IP routing table for routing issues, diagnosing Quality of Service (QoS) issues, checking SSH access for an upcoming audit.

Going further, you could also use nested logic and loops to check values, and then perform updates. These scripts could be included in Continuous Delivery (CD) pipelines as part of application deployments that require network updates. This would give tracking ability to network changes during application deployments.

Follow the instructions to get this basic plan working.

1. Create a plan directory in your module and create a new file called `sampleplan.pp` with the following content:
```
plan cisco_ios::sampleplan (TargetSpec $nodes) {
  #check if ping to a specific IP is successful
  $pingresults = run_task('cisco_ios::cli_command', $nodes, command => 'ping 2.2.2.2', raw => false)
  if ($pingresults.first['results'] =~ 'Success rate is 0 percent') {
    warning("Ping failed!")
  } else {
    notice("Ping successful.")
  }

  # verify that the device is not using its own clock
  $ntpresults = run_task('cisco_ios::cli_command', $nodes, command => 'show ntp associations', raw => false)
  if ($ntpresults.first['results'] =~ '~127.') {
    warning("Device using its own clock!")
  } else {
    notice("NTP appears normal")
  }

  #check if the fan is ok
  $fanresults = run_task('cisco_ios::cli_command', $nodes, command => 'sh env fan', raw => false)
  if( $fanresults.first['results'] =~ 'FAN is OK') {
    notice("Fan is OK")
  } else {
    warning("Issue with the fan, inspect hardware")
  }

  #check if the temperature is OK
  $tempresults = run_task('cisco_ios::cli_command', $nodes, command => 'sh env temperature', raw => false)
  if( $tempresults.first['results'] =~ 'TEMPERATURE is OK') {
    notice("Temperature is OK")
  } else {
    warning("Issue with the temperature, inspect data center")
  }

  #check if any interfaces are not OK
  $interfaceresults = run_task('cisco_ios::cli_command', $nodes, command => 'show ip interface brief', raw => false)
  if( $interfaceresults.first['results'] !~ 'NO') {
    notice("Interfaces appear OK")
  } else {
    warning("Problem with some of the interfaces, output below")
    warning($interfaceresults.first['results'])
  }
}
```
As you'll notice, the plan is a set of commands and messages output to the console. More complex logic can of course be added by using the Puppet language, or just straightforward YAML - more in our [docs](https://puppet.com/docs/bolt/latest/writing_plans.html).


2. Run the plan by running the command `bolt plan run cisco_ios::sampleplan --nodes cisco_ios`. The output will be displayed in the console.

That's it! I encourage to play more with plans as they can provide huge value. The [Bolt hands-on-lab](https://github.com/puppetlabs/tasks-hands-on-lab) has more complex examples that are worth exploring.

# Next steps

That's it! You have now performed network automation with Bolt and a network device module. 

There are many other network automation tasks you can perform with Bolt. Some ideas are below.

* If you have multiple devices that you can test against, add extra nodes to the `inventory.yaml` file and your commands and manifests can be executed against them all. This may help you to, for example, report on NTP server settings across a number of devices with one command. Or you could run troubleshooting tasks across multiple devices in parallel. And you could try out bolt plans to chain together multiple commands against multiple devices. We'll add to this tutorial with additional content as time permits.
* Run Bolt on a jumphost to access devices on different network segments to your localhost using the [run-on](https://puppet.com/docs/bolt/latest/bolt_configuration_options.html#remote-transport-configuration-options) option.
* Use [bolt plans](https://puppet.com/docs/bolt/latest/writing_plans.html) for more complex automation.
* Learn more about tasks and Bolt using the [Bolt hands-on-lab](https://github.com/puppetlabs/tasks-hands-on-lab).
* Check out the [Palo Alto](https://forge.puppet.com/puppetlabs/panos/reference) module on the Forge to see what else you can automate with Puppet and Bolt.
