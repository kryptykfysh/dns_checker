# coding: utf-8

require 'active_support'
require 'active_support/core_ext'
require 'resolv'
require 'set'
require_relative 'dns_checker/domain'
require_relative 'dns_checker/nameserver'
require_relative 'dns_checker/version'

module DnsChecker
  DNS = Resolv::DNS.new

  def self.on_our_nameservers?(domain_names:, nameservers:, groups: 25)
    nameserver_ips = nameservers.each_with_object(Set.new) do |ns_name, ips|
      Nameserver.new(name: ns_name).a_records.each { |a| ips << a }
    end
    threads = []
    result = {}
    domain_names.in_groups(groups, false) do |group|
      threads << Thread.new do
        domains = group.map { |g| Domain.new(g) }
        domains.each do |domain|
          result[domain] = domain.nameserver_ips.all? { |ip| nameserver_ips.include? ip }
        end
      end
    end
    threads.map(&:join)
    result
  end
end
