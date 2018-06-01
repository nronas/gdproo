require 'thread'
require_relative 'storage'
require_relative 'models/tree'

module Gdproo
  class TreeBuilder
    def initialize
      @storage = Storage.instance
      @tree = Tree.new
    end

    def build(model, id)
      root = @storage.slice(model)
      resource = root.keys.first.constantize.find(id)
      raise "Failed to build tree for #{model}" if root.nil?

      visited = Set.new
      to_visit = Queue.new
      to_visit << root
      root[model][:resource] = resource
      @tree.add(root, nil)

      while !to_visit.empty? do
        node = to_visit.pop
        visited << node
        has_many = node.dig(node.keys.first, :has_many)
        has_one = node.dig(node.keys.first, :has_one)
        parent_resource = node.dig(node.keys.first, :resource)

        (has_one + has_many).each do |_node|
          normalized_name = _node.to_s.singularize.camelize.constantize.to_s
          new_node = @storage.slice(normalized_name)
          Array(parent_resource.send(_node)).each do |node_resource|
            node_to_be_added = new_node.deep_dup
            node_to_be_added[node_to_be_added.keys.first][:resource] = node_resource
            to_visit << node_to_be_added unless visited.include?(node_to_be_added)
            @tree.add(node_to_be_added, node)
          end
        end
      end

      @tree
    end
  end
end