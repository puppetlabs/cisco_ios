require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'github_changelog_generator/task' if Bundler.rubygems.find_name('github_changelog_generator').any?

PuppetLint.configuration.send('relative')
if Bundler.rubygems.find_name('github_changelog_generator').any?
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.user = 'puppetlabs'
    config.project = 'cisco_ios'
    config.since_tag = '0.1.0'
    config.future_release = '0.2.0'
    config.exclude_labels = ['maintenance']
    config.header = "# Change log\n\nAll notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org)."
    config.add_pr_wo_labels = true
    config.issues = false
    config.merge_prefix = "### UNCATEGORIZED PRS; GO LABEL THEM"
    config.configure_sections = {
      "Changed" => {
        "prefix" => "### Changed",
        "labels" => ["backwards-incompatible"],
      },
      "Added" => {
        "prefix" => "### Added",
        "labels" => ["feature", "enhancement"],
      },
      "Fixed" => {
        "prefix" => "### Fixed",
        "labels" => ["bugfix"],
      },
    }
  end
end
