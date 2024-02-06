module SymbolizeHelper
  extend self

  class << self
    def deep_symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        new_key = key.is_a?(String) ? key.to_sym : key
        new_value = if value.is_a?(Array)
          value.map { |item| deep_symbolize_keys(item) }
        elsif value.is_a?(Hash)
          deep_symbolize_keys(value)
        else
          value
        end
        result[new_key] = new_value
      end
    end
  end

  refine Hash do
    def deep_symbolize_keys
      SymbolizeHelper.deep_symbolize_keys(self)
    end
  end
end
