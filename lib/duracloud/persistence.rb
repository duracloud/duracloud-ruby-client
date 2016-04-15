require "active_model/callbacks"

module Duracloud
  module Persistence

    def self.included(base)
      base.class_eval do
        extend ActiveModel::Callbacks

        define_model_callbacks :save, :delete
      end
    end

    def save
      raise Error, "Cannot save deleted #{self.class}." if deleted?
      run_callbacks :save do
        do_save
        persisted!
      end
    end

    def delete
      raise Error, "Cannot delete, already deleted." if deleted?
      run_callbacks :delete do
        do_delete
        deleted!
        freeze
      end
    end

    def persisted?
      !!@persisted
    end

    def deleted?
      !!@deleted
    end

    private

    def persisted!
      @persisted = true
    end

    def deleted!
      @deleted = true
      @persisted = false
    end

    def do_delete
      raise NotImplementedError, "Classes must implement `do_delete`."
    end

    def do_save
      raise NotImplementedError, "Classes must implement `do_save`."
    end

  end
end
