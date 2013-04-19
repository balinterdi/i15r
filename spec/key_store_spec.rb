require 'spec_helper'

describe KeyStore do
  let(:original) { {} }
  let(:key_store) { KeyStore.new(original) }

  it "adds a value to a provided namespace" do
    key_store.add_key %w( one two three four ), 'value'
    key_store['one']['two']['three']['four'].should == 'value'
  end

  context "merging" do
    let(:original) { { 'one' => { 'two' => { 'three' => { 'four' => 'value' } } } } }
    let(:merge_hash) { { 'one' => { 'two' => { 'three' => { 'five' => 'merge_hash_value' } } } } }

    it "deep merges another hash with itself" do
      key_store.deep_merge(merge_hash).should == { 'one' => { 'two' => { 'three' => { 'four' => 'value', 'five' => 'merge_hash_value' } } } }
    end

    context "with conflicts" do
      let(:merge_hash) { { 'one' => { 'two' => { 'three' => { 'four' => 'merge_hash_value' } } } } }

      it "defaults to the merged hash value" do
        key_store.deep_merge(merge_hash).should == merge_hash
      end

      it "delegates resolution to a proc if provided" do
        conflict_proc = ->(key, namespaced_key, original_value, merge_value){ original_value }
        key_store.deep_merge(merge_hash, conflict_proc).should == original
      end
    end
  end

  context "sorting" do
    let(:original) { { 'one' => { 'two' => { 'three' => { 'c' => 'z', 'z' => 'a', 'a' => 'c' } } } } }

    it "sorts with the key by default" do
      key_store.deep_sort.should == { 'one' => { 'two' => { 'three' => { 'a' => 'c', 'c' => 'z', 'z' => 'a' } } } }
    end

    it "delegates sort value to proc if provided" do
      sort_proc = ->(key, value){ value }
      key_store.deep_sort(sort_proc).should == { 'one' => { 'two' => { 'three' => { 'z' => 'a', 'a' => 'c', 'c' => 'z' } } } }
    end
  end
end
