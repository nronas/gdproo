require_relative 'tree_builder'

module Gdproo
  class Deleter
    def initialize(entity)
      @entity = entity
      @tree_builder = TreeBuilder.new
    end

    def delete(id:, id_field: :id)
      tree = build_tree(id, id_field)

      tree.preorder do |node|
        resource = node.resource
        if resource && node.deletable?
          puts "Deleting -> #{node.resource.class}:#{node.resource.id}"
          resource.delete
          sleep(ENV.fetch('GDPR_DELETER_INTERVAL_SLEEP_WINDOW', 1).to_i)
        end
      end
    end

    private

    def build_tree(id, id_field)
      if @entity
        @tree_builder.build(@entity, id, id_field)
      else
        raise 'Unsupported entity'
      end
    end
  end
end
