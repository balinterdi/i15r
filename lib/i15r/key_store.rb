require 'delegate'
# stores parsed keys in a hash format for use in merging with and
# writing back to the locale file
class KeyStore < SimpleDelegator
  def add_key(namespace, value)
    apply_value! __getobj__, value, namespace
    __getobj__
  end

  def deep_merge(merge_hash, conflict_proc = nil, &conflict_block)
    conflict_proc ||= conflict_block
    merged = DeepMerger.merge __getobj__, merge_hash, conflict_proc
    self.class.new merged
  end

  def deep_sort(sort_proc = nil, &sort_block)
    sort_proc ||= sort_block || ->(key, value){ key }
    sorted = DeepSorter.sort __getobj__, sort_proc
    self.class.new sorted
  end

  private

  def apply_value!(object, value, namespace)
    object ||= {}
    return value if namespace.empty?
    current = namespace.shift
    object[current] = apply_value!(object[current], value, namespace)
    object
  end

  module DeepMerger
    def self.merge(hash, merge_hash, conflict_proc)
      hash.merge(merge_hash) do |key, hash_val, merge_hash_val|
        if hash_val.kind_of?(Hash) && merge_hash_val.kind_of?(Hash)
          merge hash_val, merge_hash_val, conflict_proc
        else
          if conflict_proc
            conflict_proc.call(key, hash_val, merge_hash_val)
          else
            merge_hash_val
          end
        end
      end
    end
  end

  module DeepSorter
    def self.sort(hash, sort_proc)
      Hash[hash.sort_by { |k, v| sort_proc.call(k, v) }].tap do |new_hash|
        new_hash.keys.each do |k|
          if new_hash[k].kind_of?(Hash)
            new_hash[k] = sort new_hash[k], sort_proc
          end
        end
      end
    end
  end

end
