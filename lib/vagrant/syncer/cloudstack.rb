#!/usr/bin/env ruby
require "yaml"
require "cloudstack_client"
require "pathname"

module Vagrant
  module Syncer
    # Vagrant::Syncer::Cloudstack
    class Cloudstack
      @client = nil, @machines = nil, @group_id = nil

      def initialize(url, api_key, secret_key, group_name)
        @url = url
        @api_key = api_key
        @secret_key = secret_key
        @group_name = group_name
      end

      def client
        return @client if @client
        @client = CloudstackClient::Client.new(@url, @api_key, @secret_key)
      end

      def find_dups(array)
        array.find_all { |e| array.count(e) > 1 }
      end

      def find_group_id_by_name(name)
        groups = list_instance_groups_by_name(name)
        raise "cannot find group by `#{name}`" if groups.length.zero?
        if groups.length > 1
          raise "multiple groups with same group name `#{name}` returned"
        end
        groups.first["id"]
      end

      def list_instance_groups_by_name(name)
        client.list_instance_groups(name: name)
      end

      def list_virtual_machines_by_group_id(id)
        client.list_virtual_machines(group_id: id)
      end

      def group_id
        return @group_id if @group_id
        @group_id = find_group_id_by_name(@group_name)
      end

      def machines
        return @machines if @machines
        @machines = list_virtual_machines_by_group_id(group_id)
        dups = find_dups(@machines.map { |vm| vm["displayname"] })
        unless dups.empty?
          raise "found multiple VMs with same displayname: #{dups.join(' ')}"
        end
        @machines
      end

      def create_machine_directory(name)
        FileUtils.mkdir_p(machine_directory(name))
      end

      def machine_directory(name)
        Pathname.new(".vagrant/machines/#{name}/cloudstack").to_s
      end

      def local_id_file(name)
        (Pathname.new(machine_directory(name)) + "id").to_s
      end

      def open_local_id_file_for_write(name)
        File.open(local_id_file(name), "w")
      end

      def local_id(name)
        id = nil
        begin
          id = File.read(local_id_file(name))
        rescue Errno::ENOENT
          id = ""
        end
        id
      end

      # rubocop:disable Metrics/AbcSize
      def remote_id(name)
        id = ""
        found_vms = machines.select { |vm| vm["displayname"] == name }
        if found_vms.length == 1
          id = found_vms.first["id"]
        elsif !found_vms.empty?
          found_ids = found_vms.map { |vm| vm["id"] }.join(" ")
          raise format("multiple VMs returned for `%s`: %s", name, found_ids)
        end
        id
      end
      # rubocop:enable Metrics/AbcSize

      def write_id_to_file(name)
        if remote_id(name).nil? || remote_id(name).empty?
          raise "cannot find remote id for `#{name}`"
        end
        puts format(
          "writing id `%s` to file `%s` for `%s`",
          remote_id(name), local_id_file(name), name
        )
        file = open_local_id_file_for_write(name)
        file.write remote_id(name)
        file.close
      end

      def sync(vm)
        name = vm["displayname"]
        create_machine_directory(name)
        if local_id(name).empty?
          write_id_to_file(name)
        elsif local_id(name) != remote_id(name)
          raise format(
            "VM `%s` has conflicting IDs: remote: `%s` local: `%s`",
            name, remote_id(name), local_id(name)
          )
        end
      end

      def run
        machines.each { |vm| sync(vm) }
      end
    end
  end
end
