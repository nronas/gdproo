require 'singleton'

module Gdproo
  class Storage
    include Singleton

    def initialize
      @store = {}
    end

    def slice(key)
      @store.slice(key)
    end

    def insert(model, name:, field:, description:)
      @store[model.to_s] ||= initial_entry
      @store[model.to_s][:fields] << {name: name, accessor: field, description: description}
    end

    def insert_relation(model, has_many:, has_one:, skip:, deletable:)
      @store[model.to_s] ||= initial_entry
      @store[model.to_s][:has_many] += has_many
      @store[model.to_s][:has_one] += has_one
      @store[model.to_s][:skip] = skip
      @store[model.to_s][:deletable] = deletable
    end

    def initial_entry
      {
        has_one: [],
        has_many: [],
        fields: [],
        skip: false,
        deletable: true,
      }
    end
  end
end
