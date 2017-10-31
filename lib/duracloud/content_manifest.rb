require 'nokogiri'
require 'hashie'

module Duracloud
  class ContentManifest < Hashie::Dash

    property :space_id, required: true
    property :manifest_id, required: true
    property :store_id

    def self.find(**kwargs)
      new(**kwargs).tap do |manifest|
        manifest.content
      end
    end

    def content
      @content ||= Content.new(space_id: space_id, content_id: manifest_id, store_id: store_id).tap do |c|
        c.load_properties
      end
    end

    def source
      @source ||= Source.new(self)
    end

    def xml
      @xml ||= content.download.body
    end

    protected

    def method_missing(name, *args, &block)
      if content.respond_to?(name)
        content.send(name, *args, &block)
      else
        super
      end
    end

    class Source
      attr_reader :manifest

      def initialize(manifest)
        @manifest = manifest
      end

      def doc
        @doc ||= Nokogiri::XML(manifest.xml)
      end

      def md5
        doc.css("sourceContent md5").text
      end

      def content_id
        doc.css("sourceContent").first["contentId"]
      end

      def size
        doc.css("sourceContent byteSize").text.to_i
      end

      def content_type
        doc.css("sourceContent mimetype").text
      end

      def download(&block)
        chunks.each do |chunk|
          chunk.download(&block)
        end
      end

      def chunks
        Enumerator.new do |e|
          doc.css("chunk").each do |chunk_xml|
            e << Content.find(space_id: manifest.space_id,
                              content_id: chunk_xml["chunkId"],
                              store_id: manifest.store_id,
                              md5: chunk_xml.css("md5").text)
          end
        end
      end
    end

  end
end
