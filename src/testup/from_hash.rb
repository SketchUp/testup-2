#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

module TestUp
  module FromHash

    # @param [Hash] hash
    def from_hash(hash)
      new(*typed_values(hash))
    end

    private

    # @return [Hash{Symbol, String => Class, nil}]
    def typed_structure
      raise NotImplementedError
    end

    # @param [Hash] hash
    def typed_values(hash)
      raise ArgumentError, "expected Hash, got #{hash.class}" unless hash.is_a?(Hash)
      typed_structure.map { |key, type|
        unless hash.key?(key) || hash.key?(key.to_s)
          raise ArgumentError, "expected key #{key.inspect} not found"
        end
        value = hash.key?(key) ? hash[key] : hash[key.to_s]
        convert_type(type, value)
      }
    end

    def convert_type(type, value)
      if type.nil? || value.nil?
        value
      elsif type.is_a?(Symbol) && type == :bool
        !!value
      elsif type.is_a?(Symbol)
        value.send(type)
      elsif type.is_a?(Array)
        raise ArgumentError, "expected Array, got #{value.class}" unless value.is_a?(Array)
        value_type = type.first
        value.map { |item| convert_type(value_type, item) }
      elsif type.respond_to?(:from_hash)
        type.from_hash(value)
      else
        type.new(value)
      end
    end

  end # module
end # module
