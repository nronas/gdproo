require 'gdproo/version'
require 'gdproo/storage'
require 'active_support/all'

module Gdproo
  extend ActiveSupport::Concern

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    def consent_relations(has_one: [], has_many: [], skip: false, deletable: true)
      Storage.instance.insert_relation(self.to_s,
                                       has_many: has_many,
                                       has_one: has_one,
                                       skip: skip,
                                       deletable: deletable)
    end

    def consent(name:, field:, description:)
      Storage.instance.insert(self.to_s,
                              name: name,
                              description: description,
                              field: field)
    end
  end
end
