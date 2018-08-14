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
            next res if node.resource.nil?
            next res if value_for(node.resource, field).nil?

            res << data_line_for(node, field)
          end
        end
      end

      @lines
    end

    private

    def data_line_for(node, field)
      {
        entity: @entity,
        service_name: ENV.fetch('GDPR_SERVICE_NAME', ''),
        name: field[:name],
        table_name: node.resource.class.table_name,
        resource_id: node.resource.id,
        value: value_for(node.resource, field).to_s
      }
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
