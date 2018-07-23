require_relative 'tree_builder'

module Gdproo
  class Auditer
    def initialize(entity)
      @entity = entity
      @lines = []
      @tree_builder = TreeBuilder.new
    end

    def audit(id:, id_field: :id)
      tree = build_tree(id, id_field)

      tree.dfs do |node|
        if node.children.empty? || node.fields.present?
          @lines += node.fields.inject([]) do |res, field|
            next res if value_for(node.resource, field).nil?

            if node.skipped?
              res << ["#{node.prefix}#{field[:name]}", value_for(node.resource, field).to_s, field[:description]]
            else
              res << ["#{node.prefix}#{node.name.split('::').last.underscore}.#{node.resource.id}.#{field[:name]}", value_for(node.resource, field).to_s, field[:description]]
            end
          end
        end

        node.children.each do |child|
          child.prefix += node.prefix

          unless node.skipped?
            child.prefix += "#{node.name.split('::').last.underscore}.#{node.resource.id}."
          end
        end
      end

      @lines
    end

    def value_for(resource, field)
      if field[:accessor].is_a?(Proc)
        field[:accessor].call(resource)
      else
        resource&.send(field[:accessor])
      end
    end

    def build_tree(id, id_field)
      if @entity
        @tree_builder.build(@entity, id, id_field)
      else
        raise 'Unsupported entity'
      end
    end
  end
end
