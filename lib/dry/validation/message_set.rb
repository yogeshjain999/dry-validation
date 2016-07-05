require 'dry/validation/constants'

module Dry
  module Validation
    class MessageSet
      include Enumerable

      attr_reader :messages, :hints

      def self.[](messages)
        new(messages.flatten)
      end

      def initialize(messages)
        @messages = messages
        @hints = []
      end

      def empty?
        messages.empty?
      end

      def each(&block)
        return to_enum unless block
        messages.each(&block)
      end

      def with_hints!(hints)
        @hints = hints
        freeze
      end

      def to_h
        hash = {}

        map(&:path).uniq.each do |path|
          last = path.last
          path.reduce(hash) do |a, e|
            a[e] || a[e] = e == last ? [] : {}
          end
        end

        each do |msg|
          if msg.root?
            (hash[nil] ||= []) << msg.to_s
          else
            node = msg.path.reduce(hash) { |a, e| a[e] }
            node << msg
            node.concat(hints.select { |hint| hint.add?(msg) })
            node.uniq!(&:signature)
            node.map!(&:to_s)
          end
        end

        hash
      end
      alias_method :to_hash, :to_h
    end
  end
end
