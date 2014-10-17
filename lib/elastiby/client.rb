require 'net/http'
require_relative 'serializer'

module Elastiby
  class Client
    attr_reader :server, :port, :format

    def initialize server, options = {}
      @server = server
      @port = options[:port] || 9200
      @format = options[:format] || :null
    end

    def to_s
      "http://#{@server}:#{@port}/"
    end

    def get path = '/'
      @serializer ||= SerializerFactory.create(@format)
      @serializer.unserialize(Net::HTTP.get(@server, path, @port))
    end

    def post path, payload
      @serializer ||= SerializerFactory.create(@format)
      response = Net::HTTP.new(@server, @port).post(path, @serializer.serialize(payload))
      @serializer.unserialize(response.body)
    end

    def put path, payload
      @serializer ||= SerializerFactory.create(@format)
      response = Net::HTTP.new(@server, @port).put(path, @serializer.serialize(payload))
      @serializer.unserialize(response.body)
    end

    def head path = '/'
      @serializer ||= SerializerFactory.create(@format)
      Net::HTTP.new(@server, @port).head(path)
    end
  end
end
