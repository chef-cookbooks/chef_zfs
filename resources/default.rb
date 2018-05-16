# -*- encoding: utf-8 -*-
#
# Author:: Ryan Hass (<rhass@chef.io>)
# Author:: Martha Greenberg (<marthag@mit.edu>)
# Copyright (C) 2017, Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource_name :zfs
property :properties, Array

load_current_value do
  current_value_does_not_exist! unless zfs_exist?(name)
  properties zfs_properties(name)
end

action :create do
  if current_resource
    zfs_set_properties(new_resource.name, new_resource.properties) unless new_resource.properties.nil?
  else
    cmd = %w(zfs create)
    new_resource.properties.each do |setting|
      key = setting.keys.first
      cmd << '-o'
      cmd << "#{key}=#{setting[key]}"
    end unless new_resource.properties.nil?
    cmd << new_resource.name

    execute 'zfs_create' do
      environment 'PATH' => "/usr/sbin:#{ENV['PATH']}" if platform_family?('solaris2')
      command cmd
    end
  end
end

action :destroy do
  execute 'zfs_destroy' do
    environment 'PATH' => "/usr/sbin:#{ENV['PATH']}" if platform_family?('solaris2')
    command "zfs destroy #{new_resource.name}"
  end
end

action :upgrade do
  execute 'zfs_upgrade' do
    environment 'PATH' => "/usr/sbin:#{ENV['PATH']}" if platform_family?('solaris2')
    command "zfs upgrade #{new_resource.name}"
  end
end

PROPERTIES_VALID_ONLY_AT_CREATE = [
  :casesensitivity,
  :normalization,
  :utf8only,
  :volblocksize,
].freeze

# Method to coalesce the zfs get command output against the parser method.
def zfs_properties(name)
  properties || parse_zfs_properties(zfs_get_properties(name))
end

# private

# Helper method to check if a filesystem exists.
# @parm [String] ZFS Name
# @return [Boolean]
def zfs_exist?(name)
  cmd = Mixlib::ShellOut.new('zfs', 'get', 'mountpoint', name)
  cmd.environment['PATH'] = "/usr/sbin:#{ENV['PATH']}" if platform_family?('solaris2')
  cmd.run_command
  cmd.exitstatus == 0
end

def zfs_get_properties(name)
  cmd = Mixlib::ShellOut.new('zfs', 'get', 'all', name)
  cmd.environment['PATH'] = "/usr/sbin:#{ENV['PATH']}" if platform_family?('solaris2')
  cmd.run_command
  cmd.error!
  cmd.stdout
end

# TODO: Add support for setting inheritance from parent filesystems.
# @param [String] ZFS Name
# @param [Hash] ZFS Property => value
def zfs_set_properties(fs, properties)
  # There are a handlful of properties which can only be set when the
  # filesystem is created. We do not try to set these values since we
  # cannot change these settings.
  configurable_properties = properties.reject do |setting|
    PROPERTIES_VALID_ONLY_AT_CREATE.include?(setting.keys.first)
  end

  configurable_properties.each do |setting|
    next if PROPERTIES_VALID_ONLY_AT_CREATE.include?(setting.keys[0])
    cmd = Mixlib::ShellOut.new('zfs', 'set', "#{setting.keys[0]}=#{setting[setting.keys[0]]}", fs)
    cmd.environment['PATH'] = "/usr/sbin:#{ENV['PATH']}" if platform_family?('solaris2')
    cmd.run_command
    cmd.error!
  end
end

#
# @param [String] output of `zfs get all <filesystem>`
# @return [Array] Hash of propetry value and the source of the ZFS values.
# @example Parse zfs get all command output
#   parse_zfs_properties <<EOF
#   NAME                          PROPERTY              VALUE                              SOURCE
#   tank                          type                  filesystem                         -
#   tank/myfs                     atime                 off                                inherited from tank
#   tank/myfs                     checksum              on                                 default
#   tank/myfs                     dedup                 off                                local
#   EOF
#   #=> [ {:atime=>"off", :source=>"tank"},
#    {:checksum=>"on", :source=>"default"},
#    {:dedup=>"off", :source=>"local"}]
def parse_zfs_properties(props)
  properties_array = props.split(/\n/).drop(1).select { |p| p if p.split.last != '-' }.map(&:split)
  properties_array.map do |property|
    {
      property[1].to_sym => property[2],
      source: property[3] == 'inherited' ? property[5] : property[3],
    }
  end
end
