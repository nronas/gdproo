require 'gdproo/version'
require 'gdproo/storage'
require 'gdproo/auditer'
require 'active_support/all'

module Gdproo
  extend ActiveSupport::Concern

  class_methods do
    def consent_relations(has_one: [], has_many: [])
      Storage.instance.insert_relation(self.to_s, has_many: has_many, has_one: has_one)
    end

    def consent(name:, field:, description:)
      Storage.instance.insert(self.to_s,
                              name: name,
                              description: description,
                              field: field)
    end
  end
end