require 'thread'
require_relative 'storage'
require_relative 'models/tree'

module Gdproo
  class TreeBuilder
    def initialize
      @tree = Tree.new
    end

    def build(model, id)
      root = storage.slice(model)
      resource = root.keys.first.constantize.find(id)
      raise "Failed to build tree for #{model}" if root.nil?

      visited = Set.new
      to_visit = Queue.new
      to_visit << root
      root[model][:resource] = resource
      @tree.add(root, nil)

      while !to_visit.empty? do
        node = to_visit.pop
        puts "Processing node: #{node}"
        visited << node
        has_many = node.dig(node.keys.first, :has_many)
        has_one = node.dig(node.keys.first, :has_one)
        parent_resource = node.dig(node.keys.first, :resource)

        has_one.each do |_node|
          puts "Generate child nodes for: #{_node}"
          normalized_name = parent_resource.class.reflect_on_association(_node)&.class_name || _node.camelize
          normalized_name.constantize
          new_node = storage.slice(normalized_name)
          node_resource = parent_resource.send(_node)
          node_to_be_added = new_node.deep_dup
          node_to_be_added[node_to_be_added.keys.first][:resource] = node_resource
          to_visit << node_to_be_added unless visited.include?(node_to_be_added)
          @tree.add(node_to_be_added, node)
        end

        has_many.each do |_node|
          puts "Generate child nodes for: #{_node}"
          normalized_name = parent_resource.class.reflect_on_association(_node).class_name || _node.camelize
          normalized_name.constantize
          new_node = storage.slice(normalized_name)
          parent_resource.send(_node).find_in_batches(batch_size: 100) do |batch|
            batch.each do |node_resource|
              node_to_be_added = new_node.deep_dup
              node_to_be_added[node_to_be_added.keys.first][:resource] = node_resource
              to_visit << node_to_be_added unless visited.include?(node_to_be_added)
              @tree.add(node_to_be_added, node)
            end
          end
        end
      end

      @tree
    end

    def storage
      Storage.instance
    end
  end
end
