# Download the Puppet Cisco IOS module

Use Bolt to download the [Cisco IOS module](https://forge.puppet.com/puppetlabs/cisco_ios) from [the Forge](https://forge.puppet.com/) to your local workstation. In this lab, you will create a [local project directory](https://puppet.com/docs/bolt/latest/bolt_project_directories.html#local-project-directory).

The Cisco IOS module has a dependency on another Puppet module: the network device standard library, otherwise known as [netdev_stdlib](https://forge.puppet.com/puppetlabs/netdev_stdlib). This needs to be installed along with the module.

1. Create a folder in your preferred location and navigate to it.

2. Inside the new folder, create a `bolt.yaml` file and a `Puppetfile` file.

3. Edit the `Puppetfile` file to tell Bolt where to look for the modules, which modules to retrieve, and the version of the modules:

```
mod 'puppetlabs-cisco_ios', '0.6.2'
mod 'puppetlabs-netdev_stdlib', '0.18.0'
mod 'puppetlabs-resource_api', '1.1.0'
```

> Note: If you are familiar with Puppet, notice that it uses the same format as Puppet files. it is recommended to use the latest version of the relevant modules from the Forge, so update the version numbers above to be the latest released version numbers.

4. From the command line, install the modules with Bolt:

`bolt puppetfile install`

Once the modules have been installed, you should get the following message: 

`Successfully synced modules from $(pwd)/Puppetfile to $(pwd)/modules`

6. To verify that the modules have been installed correctly, look for a `modules` folder in your Bolt working directory. Run `ls $(pwd)/modules` and you should see two folders, one called `cisco_ios` and another called `netdev_stdlib` containing the modules downloaded from the Forge.

7. To see a list of the tasks that Bolt can access on your local machine, run `bolt task show`. You should see the tasks included in the list of available tasks:

```
cisco_ios::cli_command           Execute CLI Command
cisco_ios::config_save           Save running-config to startup-config
```

# Next steps

Now that you have installed the module, you will configure the device in an `inventory.yaml` file.

[Update bolt Inventory](./../03-update-bolt-inventory/README.md)
