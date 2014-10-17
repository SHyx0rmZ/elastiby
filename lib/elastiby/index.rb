module Elastiby
  class Index
    attr_reader :name

    def initialize client, name
      @client, @name = client, name
    end

    def to_s
      "#{@client}#{@name}"
    end

    def exists?
      @client.head("/#{name}").kind_of?(Net::HTTPSuccess) ? true : false
    end

    def self.create client, name, options = {}
      index = Index.new(client, name)

      unless options[:ignore_existing]
        raise StandardError, 'Index already exists' if index.exists?
      end

      unless index.exists?
        mappings = options[:mappings]
        settings = options[:settings] || { settings: {} }
        shards = options[:shards] || 5
        replicas = options[:replicas] || 1

        settings[:settings].merge!({ number_of_shards: shards, number_of_replicas: replicas })
        settings[:mappings] = mappings unless mappings.nil?

        client.post("/#{name}/", settings)
      end

      index
    end

    def each_type
      mappings = @client.get("/#{name}/_mapping")
      mappings[name.to_sym][:mappings].each {|type| yield(type[0].to_s) }
    end
  end
end
