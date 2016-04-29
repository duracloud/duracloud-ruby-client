module Duracloud
  module HasProperties

    def self.included(base)
      base.class_eval do
        include Persistence

        before_delete :reset_properties
        after_save :reset_properties
      end
    end

    # Return the properties associated with this resource,
    #   loading from Duracloud if necessary.
    # @return [Duracloud::Properties] the properties
    # @raise [Duracloud::NotFoundError] if the resource is marked persisted
    #   but does not exist in Duracloud
    def properties
      load_properties if persisted? && @properties.nil?
      @properties ||= properties_class.new
    end

    # @api private
    # @raise [Duracloud::NotFoundError] the resource does not exist in DuraCloud.
    def load_properties
      response = get_properties_response
      self.properties = response.headers
      yield response if block_given?
      persisted!
    end

    private

    def properties=(props)
      filtered = props ? properties_class.filter(props) : props
      @properties = properties_class.new(filtered)
    end

    def reset_properties
      @properties = nil
    end

    def properties_class
      Properties
    end

    def get_properties_response
      raise NotImplementedError, "Class must implement `get_properties_response`."
    end

  end
end
