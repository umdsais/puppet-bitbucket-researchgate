require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.default_facts = {
    bitbucket_version: '4.6.0',
    staging_http_get: 'curl',
    os_maj_version: '6',
    puppetversion: '3.7.4',
  }

  # Filter backtrace noise
  backtrace_exclusion_patterns = [
    %r{spec_helper},
    %r{gems},
  ]

  if c.respond_to?(:backtrace_exclusion_patterns)
    c.backtrace_exclusion_patterns = backtrace_exclusion_patterns
  elsif c.respond_to?(:backtrace_clean_patterns)
    c.backtrace_clean_patterns = backtrace_exclusion_patterns
  end
end

BITBUCKET_VERSION = '4.6.0'.freeze
BACKUP_VERSION = '3.6.0'.freeze
BITBUCKET_BACKUP_VERSION = '3.6.0'.freeze

# 'spec_overrides' from sync.yml will appear below this line
