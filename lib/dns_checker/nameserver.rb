# coding: utf-8

require 'resolv'
require_relative '../dns_checker'

module DnsChecker
  class Nameserver
    attr_reader :a_records
    attr_reader :name
    attr_reader :ttl

    def initialize(name:, ttl: nil)
      @name = name
      @ttl = ttl
      update_a_records
    end

    private

    def update_a_records
      @a_records = DNS.getresources(@name, Resolv::DNS::Resource::IN::A).map do |rec|
        rec.address.to_s
      end
    end
  end
end
