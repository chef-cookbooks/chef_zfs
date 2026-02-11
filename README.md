# Archived Repository

This repository has been archived and will no longer receive updates. 
It was archived as part of the [Repository Standardization Initiative](https://github.com/chef-boneyard/oss-repo-standardization-2025).
If you are a Chef customer and need support for this repository, please contact your Chef account team.

# chef_zfs Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/chef_zfs.svg?branch=master)](https://travis-ci.org/chef-cookbooks/chef_zfs) [![Cookbook Version](https://img.shields.io/cookbook/v/chef_zfs.svg)](https://supermarket.chef.io/cookbooks/chef_zfs)

A resource for managing ZFS filesystems. This cookbook is forked from the original zfs cookbook by Martha Greenberg at <https://github.com/marthag8/zfs>.

## Requirements

### Platforms

- Ubuntu
- FreeBSD
- Solaris

### Chef

- Chef 12.7+

### Cookbooks

- none

## Resources

### zfs

#### Actions

- `:create`
- `:upgrade`
- `:destroy`

#### Properties

- `properties`: ZFS properties are set as an Array of Hashes to configure the filesystems using the single `properties` attribute.

#### Examples

##### Creating a ZFS Filesystem

```ruby
zfs "tank/test" do
  properties [
    { mountpoint: '/opt/test' },
    { relatime: 'on' },
    { compression: 'lz4' }
  ]
  action :create
end
```

##### Upgrading a ZFS to the latest filesystem version:

```ruby
zfs "tank/test" do
  action :upgrade
end
```

```ruby
zfs "tank/test" do
  properties [
    { mountpoint: '/opt/test' },
    { relatime: 'on' },
    { compression: 'lz4' }
  ]
  action [:create, :upgrade]
end
```

##### Destroying a ZFS Filesystem

```ruby
zfs "tank/test" do
  action :destroy
end
```

:sparkles: Note that destroy flags are not directly supported. However, some like the `-d` flag can be used by setting the `defer_destroy` property on the filesystem prior to destruction. See the example below.

```ruby
filesystem = zfs "tank/test" do
  properties [
    { defer_destroy: 'on' }
  ]
  action :create
  only_if "zfs list | grep -q #{self.name}"
end

zfs filesystem.name do
  action :destroy
end
```

## Maintainers

This cookbook is maintained by Chef's Community Cookbook Engineering team. Our goal is to improve cookbook quality and to aid the community in contributing to cookbooks. To learn more about our team, process, and design goals see our [team documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/COOKBOOK_TEAM.MD). To learn more about contributing to cookbooks like this see our [contributing documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/CONTRIBUTING.MD), or if you have general questions about this cookbook come chat with us in #cookbok-engineering on the [Chef Community Slack](http://community-slack.chef.io/)

## License

**Copyright:** 2012-2017, Martha Greenberg **Copyright:** 2017, Chef Software, Inc.

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
