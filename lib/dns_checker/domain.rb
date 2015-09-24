# coding: utf-8

require 'resolv'
require 'set'
require_relative 'nameserver'

module DnsChecker
  class Domain
    attr_reader :name
    attr_reader :nameservers

    def initialize(name)
      @name = name
      update_nameservers
    end

    def nameserver_ips
      @nameservers.each_with_object(Set.new) do |ns, result|
        ns.a_records.each { |rec| result << rec }
      end.to_a
    end

    private

    def update_nameservers
      @nameservers = DNS.getresources(
        @name, Resolv::DNS::Resource::IN::NS
      ).map { |ns| DnsChecker::Nameserver.new(name: ns.name.to_s, ttl: ns.ttl) }
    end
  end
end
