module Elastiby
  class Type
    attr_reader :name

    def initialize index, name
      @index, @name = index, name
    end

    def to_s
      "#{@index}/#{@name}"
    end

    def get id
      type = name

      @index.instance_eval do
        @client.get "/#{name}/#{type}/#{id}"
      end
    end

    def scroll
      type = name
      index = @index

      response = @index.instance_eval do
        @client.post("/#{name}/#{type}/_search?scroll=1m&search_type=scan", { query: { match_all: {} } })
      end

      Enumerator.new(response[:hits][:total]) do |yielder|
        index.instance_eval do
          begin
            response[:hits][:hits].each {|hit| yielder << hit }
            response = @client.post("/_search/scroll?scroll=1m&scroll_id=#{response[:_scroll_id]}", {})
          end until response[:hits][:hits].size.eql?(0)
        end
      end
    end

    def put_document document, id = nil
      type = name
      optional_id = id.nil? ? '' : "/#{id}"

      @index.instance_eval do
        @client.post("/#{name}/#{type}#{optional_id}", document)
      end
    end
  end
end
