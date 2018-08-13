name             'chef_zfs'
maintainer       'Chef Software Inc.'
maintainer_email 'cookbooks@chef.io'
license          'Apache-2.0'
description      'Manage ZFS'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.14'
source_url       'https://github.com/chef-cookbooks/chef_zfs'
issues_url       'https://github.com/chef-cookbooks/chef_zfs/issues'

%w(solaris2 ubuntu freebsd).each do |os|
  supports os
end

chef_version '>= 12.7'
