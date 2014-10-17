require 'json'

module Elastiby
  class Serializer
    def self.format
      raise StandardError, 'Not implemented'
    end

    def serialize object
      raise StandardError, 'Not implemented'
    end

    def unserialize string
      raise StandaradError, 'Not implemented'
    end
  end

  class NullSerializer < Serializer
    def self.format
      :null
    end

    def serialize object
      object
    end

    def unserialize string
      string
    end
  end

  class JsonSerializer < Serializer
    def self.format
      :json
    end

    def serialize object
      JSON.generate(object)
    end

    def unserialize string
      JSON.parse(string, symbolize_names: true)
    end
  end

  class SerializerFactory
    serializers = {}

    Elastiby.constants.each do |constant|
      next unless constant[/.+Serializer$/]

      serializer = Elastiby.const_get(constant) || Serializer
      format = serializer.format

      raise StandardError, 'Duplicate format' if serializers.include?(format)

      serializers[format] = serializer
    end

    self.class.send :define_method, :create do |format|
      serializers[format.to_sym].new
    end
  end
end
