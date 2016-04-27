require "date"
require "nokogiri"
require "forwardable"

module Duracloud
  class Space
    extend Forwardable
    include Persistence
    include HasProperties

    MAX_RESULTS = 1000

    def self.all
      response = Client.get_spaces
      doc = Nokogiri::XML(response.body)
      doc.css('space').map { |s| new(s['id']) }
    end

    def self.create(id)
      # TODO
    end

    def self.find(id)
      space = new(id)
      space.load_properties
      space
    end

    attr_reader :id

    delegate [:count, :created] => :properties

    after_save :reset_acls
    before_delete :reset_acls

    def initialize(id)
      @id = id
    end

    def acls
      @acls ||= SpaceAcls.new(self)
    end

    def each(prefix: nil)
      raise Error, "Space not yet persisted." unless persisted?
      num = 0
      while num < count
        response = Client.get_space(id, query: {prefix: prefix, max_results: MAX_RESULTS})
        xml = Nokogiri::XML(response.body)
        content_ids = xml.css('item').map(&:text)
        content_ids.each do |content_id|
          yield content_id
        end
        num += content_ids.length
      end
    end

    def each_item(prefix: nil)
      each(prefix: prefix) do |content_id|
        yield Content.find(self, content_id)
      end
    end

    private

    def reset_acls
      @acls = nil
    end

    def create
      Client.create_space(id)
    end

    def update
      Client.set_space_acls(id, acls)
    end

    def properties_class
      SpaceProperties
    end

    def get_properties_response
      Client.get_space_properties(id)
    end

    def do_delete
      Client.delete_space(id)
    end

    def do_save
      if persisted?
        update
      else
        create
      end
    end

  end
end
