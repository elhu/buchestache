require 'buchestache/outputs/io'
require 'logstash/event'

class Buchestache
  STORE_NAME = 'buchestache'

  class << self
    def store
      Thread.current[@store_name] ||= Hash.new { |hash, key| hash[key] = {} }
    end

    def configure!(conf = {})
      @source = conf[:source] || STORE_NAME
      @base_tags = [conf[:tags] || []].flatten
      @output = conf[:output] || Outputs::IO.new(Outputs::IO::default_io)
      @store_name = conf[:store_name] || STORE_NAME
      @dump_if_empty = conf.has_key?(:dump_if_empty) ? conf[:dump_if_empty] : true
      @configured = true
    end

    def log(tags = [])
      configure! unless configured?
      store.clear
      yield
      if !store.empty? || dump_if_empty?
        event = build_event(@source, tags)
        @output.dump(event)
      end
    end

    private
    def configured?
      @configured
    end

    def dump_if_empty?
      @dump_if_empty
    end

    def build_event(source, tags)
      LogStash::Event.new('@source' => source, '@fields' => store, '@tags' => @base_tags + tags)
    end
  end
end
