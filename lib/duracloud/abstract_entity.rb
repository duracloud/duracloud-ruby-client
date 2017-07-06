require "active_model"

module Duracloud
  class AbstractEntity
    include ActiveModel::Model
    extend ActiveModel::Callbacks

    define_model_callbacks :save, :delete, :load_properties
    after_save :persisted!
    after_save :reset_properties
    after_load_properties :persisted!
    before_delete :reset_properties
    after_delete :deleted!
    after_delete :freeze

    def save
      raise Error, "Cannot save deleted #{self.class}." if deleted?
      run_callbacks :save do
        do_save
      end
    end

    def delete
      raise Error, "Cannot delete, already deleted." if deleted?
      run_callbacks :delete do
        do_delete
      end
    end

    def persisted?
      !!@persisted
    end

    def deleted?
      !!@deleted
    end

    # Return the properties associated with this resource,
    #   loading from Duracloud if necessary.
    # @return [Duracloud::Properties] the properties
    # @raise [Duracloud::NotFoundError] if the resource is marked persisted
    #   but does not exist in Duracloud
    def properties
      load_properties if persisted? && @properties.nil?
      @properties ||= Properties.new
    end


    def load_properties
      run_callbacks :load_properties do
        do_load_properties
      end
    end

    private

    def do_load_properties
      raise NotImplementedError, "Subclasses must implement `#do_load_properties` private method."
    end

    def persisted!
      @persisted = true
    end

    def deleted!
      @deleted = true
      @persisted = false
    end

    def do_delete
      raise NotImplementedError, "Subclasses must implement `do_delete`."
    end

    def do_save
      raise NotImplementedError, "Subclasses must implement `do_save`."
    end

    def properties=(props)
      @properties = Properties.new(props)
    end

    def reset_properties
      @properties = nil
    end

    def properties_class
      Properties
    end

  end
end
