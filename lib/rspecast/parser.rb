# frozen_string_literal: true

module Rspecast
  class Parser
    @@cache = {}

    attr_accessor :logger, :file_path

    def initialize(file_path:, line_no:, recache: true)
      @file_path = file_path
      @line_no = line_no
      @recache = recache
    end

    def to_ast
      unless @recache
        if @@cache[@file_path]
          ast = @@cache[@file_path]
          logger.debug { 'return cached ast' }
        else
          ast = parse_ast
          logger.debug { 'parse ast' }
        end
      else
        ast = parse_ast
        logger.debug { 'parse ast' }
      end
      @@cache[@file_path] = ast

      block_nodes = recursive_find(ast) do |node|
        node.type == :block &&
          node.loc.first_line <= @line_no && node.loc.last_line >= @line_no
      end.compact
      rspec_path = block_nodes.map do |node|
        block_type = node.children[0].children[1]
        # TODO: skip if inside shared context/examples
        if block_type == :describe || block_type == :context || block_type == :it
          {
            type: block_type,
            value: parse_block_value(node),
            first_line: node.loc.first_line,
            last_line: node.loc.last_line
          }
        end
      end.compact
      rspec_path
    end

    private

    def parse_block_value(node)
      if node.children[0].children[2].type == :const
        desc = []
        recursive_find(node.children[0].children[2]) do |n|
          desc << n.children[1].to_s if n.children[1].is_a?(Symbol)
        end
        desc.reverse.join('::')
      elsif node.children[0].children[2].type == :str
        node.children[0].children[2].children[0]
      end
    end

    def parse_ast
      @parse_ast ||= begin
                 buffer = ::Parser::Source::Buffer.new @file_path
                 source = File.read @file_path
                 buffer.source = source
                 parser = ::Parser::CurrentRuby.new
                 parser.parse buffer
               end
    end

    def recursive_find(node, &block)
      if node.is_a?(::Parser::AST::Node)
        if block.call(node)
          if node.children.any?
            children = node.children.map do |child|
              recursive_find(child, &block)
            end.flatten
            [node] + children
          else
            [node]
          end
        else
          if node.children.any?
            children = node.children.map do |child|
              recursive_find(child, &block)
            end.flatten
            children
          else
            []
          end
        end
      else
        []
      end
    end
  end
end
