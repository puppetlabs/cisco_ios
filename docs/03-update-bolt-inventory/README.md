# Update the Bolt inventory file

Add the Cisco IOS device details to the Bolt inventory file.

1. Navigate to the directory you created in [Download Cisco IOS Module](./../02-download-cisco-ios-module/README.md).

2. Create a file called `inventory.yaml`.

3. Edit the `inventory.yaml` file to provide details of the Cisco IOS device you want to manage, including the IP of the Cisco IOS device, username, password and enable password:

```
nodes:
  - name: 1.1.1.1
    alias: cisco_ios
    config:
      transport: remote
      remote:
        remote-transport: cisco_ios
        user: <username>
        password: <password>
        enable_password: <enable password>
```

The `name` should be the IP address of the device. The module will use enable mode on the Cisco IOS device, so that password is required.

> Note: For Puppet employees visit confluence to find details of devices that are available for employees to test against. Search for Cisco IOS Module Development.

Now you can refer to your Cisco IOS device with the alias in the above `inventory.yaml` file.

# Next steps

Next, you will run a task.

[Running a Task](./../04-running-a-task/README.md)
