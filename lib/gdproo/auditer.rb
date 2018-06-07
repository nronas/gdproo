require_relative 'tree_builder'

module Gdproo
  class Auditer
    def initialize(entity, service, audit_map)
      @entity = entity
      @service = service
      @lines = []
      @tree_builder = TreeBuilder.new
      @audit_map = audit_map
    end

    def audit(id:)
      tree = build_tree(id)

      tree.dfs do |node|
        if node.children.empty? || node.fields.present?
          @lines += node.fields.inject([]) do |res, field|
            next res if node.resource.send(field[:accessor]).blank?

            if node.skipped?
              res << "#{node.prefix}#{field[:name]},#{node.resource.send(field[:accessor])},#{field[:description]}"
            else
              res << "#{node.prefix}#{node.name.downcase}.#{node.resource.id}.#{field[:name]},#{node.resource.send(field[:accessor])},#{field[:description]}"
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

    def build_tree(id)
      root = @audit_map.dig(@entity.to_sym, @service.to_sym)

      if root
        @tree_builder.build(root, id)
      else
        raise 'Unsupported service or entity'
      end
    end
  end
end
