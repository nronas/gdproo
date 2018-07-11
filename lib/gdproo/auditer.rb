require_relative 'tree_builder'

module Gdproo
  class Auditer
    def initialize(entity)
      @entity = entity
      @lines = []
      @tree_builder = TreeBuilder.new
    end

    def audit(id:)
      tree = build_tree(id)

      tree.dfs do |node|
        if node.children.empty? || node.fields.present?
          @lines += [['', '', '']]
          @lines += node.fields.inject([]) do |res, field|
            next res if node.resource&.send(field[:accessor]).blank?

            if node.skipped?
              res << ["#{node.prefix}#{field[:name]}", node.resource.send(field[:accessor]).to_s, field[:description]]
            else
              res << ["#{node.prefix}#{node.name.split('::').last.underscore}.#{node.resource.id}.#{field[:name]}", node.resource.send(field[:accessor]).to_s, field[:description]]
            end
          end
          @lines += [['', '', '']]
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

    def build_tree(id)
      if @entity
        @tree_builder.build(@entity, id)
      else
        raise 'Unsupported entity'
      end
    end
  end
end
