require 'thread'

module Gdproo
  class Node
    include Comparable

    attr_accessor :data, :children, :name, :prefix, :root

    def initialize(data: {})
      @data = data
      @name = data.keys.first
      @children = []
      @prefix = ""
    end

    def <=>(node)
      return -1 unless node

      self.name <=> node.name &&
        self.resource <=> node.resource
    end

    def fields
      @data[@name][:fields]
    end

    def resource
      @data[@name][:resource]
    end

    def skipped?
      @data[@name][:skip]
    end

    def deletable?
      !!@data[@name][:deletable]
    end
  end

  class Tree
    def initialize
      @root = nil
    end

    def add(data, parent)
      if @root.nil?
        @root = Node.new(data: data)
      else
        new_node = Node.new(data: data)
        parent = Node.new(data: parent)
        to_visit = Queue.new
        to_visit << @root

        while !to_visit.empty? do
          node = to_visit.pop

          node.children.each do |child|
            to_visit << child
          end

          if node == parent
            node.children << new_node
            break
          end
        end
      end
    end

    def preorder(node: @root, &block)
      if node
        node.children.each do |child|
          preorder(node: child, &block)
        end
        yield node
      end
    end

    def dfs(&block)
      to_visit = [@root]

      while !to_visit.empty? do
        node = to_visit.shift

        node.children.each do |child|
          to_visit.unshift(child)
        end

        yield node
      end
    end
  end
end
