require "active_model"

module Duracloud
  class AbstractEntity
    extend ActiveModel::Callbacks

    define_model_callbacks :save, :delete, :initialize

    after_save :reset_properties
    after_save :persisted!
    before_delete :reset_properties
    after_delete :deleted!
    after_delete :freeze

    attr_accessor :persisted, :deleted

    def initialize(*args)
      run_callbacks :initialize do
        super
      end
    end

    # Return the properties associated with this resource,
    #   loading from Duracloud if necessary.
    # @return [Duracloud::Properties] the properties
    # @raise [Duracloud::NotFoundError] if the resource is marked persisted
    #   but does not exist in Duracloud
    def properties
      if !@properties && persisted?
        @properties = properties_class.new(properties_response.headers)
      end
      @properties ||= properties_class.new
    end

    def save
      raise Error, "Cannot save deleted #{self.class}." if deleted?
      run_callbacks(:save) { do_save }
    end

    def delete
      raise Error, "Cannot delete, already deleted." if deleted?
      run_callbacks(:delete) { do_delete }
    end

    def persisted!
      self.persisted = true
    end

    def persisted?
      !!persisted
    end

    def deleted?
      !!deleted
    end

    private

    # def properties=(props)
    #   filtered = props ? properties_class.filter(props) : props
    #   @properties = properties_class.new(filtered)
    # end

    def reset_properties
      @properties = nil
      @proeprties_response = nil
    end

    def properties_class
      Properties
    end

    def properties_response
      @properties_response ||= get_properties_response
    end

    def get_properties_response
      raise NotImplementedError, "Class must implement `get_properties_response`."
    end

    def deleted!
      self.deleted = true
      self.persisted = false
    end

    def do_delete
      raise NotImplementedError, "Classes must implement `do_delete`."
    end

    def do_save
      raise NotImplementedError, "Classes must implement `do_save`."
    end

  end
end
