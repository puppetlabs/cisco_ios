# Install prerequisites

Before you begin, you need Bolt and a Cisco IOS device that you can test against. if you don't have a Cisco IOS device to test against Cisco provide some hosted devices on [DevNet](https://developer.cisco.com/site/networking/). Using DevNet requires an account, that you reserve a device and use a VPN to connect to DevNet. For this reason, it's advised to use a device that you have already, or use a Cisco IOS virtual device that may be available with your Cisco IOS support contract.

To set up your software pre-requisites follow these steps:

1. Install the latest version of Bolt. See [Installing Bolt
](https://puppet.com/docs/bolt/latest/bolt_installing.html) for instuctions. To check that Bolt has been installed, run `bolt --version`, which shows you the Bolt version number.

2. You need to be able to connect to the device from the host that you are running. You can check this by trying to SSH to the device from a terminal window. Type `ssh admin@1.1.1.1` in a terminal to see if you can access your device from your local machine. If the device is on a subnet not accessible to your local machine it is possible to run Bolt on a jump-host by adding the [run-on](https://puppet.com/docs/bolt/latest/bolt_configuration_options.html#remote-transport-configuration-options) option.

# Next steps

You are now set to start the lab. Next up we will use Bolt to download the Cisco IOS module.

[Download the Cisco IOS Module](./../02-download-cisco-ios-module/README.md)
