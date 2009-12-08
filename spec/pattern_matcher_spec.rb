$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib")

require 'i15r/pattern_matcher'
require "spec"

describe I15R::PatternMatchers::Base do
  it "should not replace a simple haml div tag with an id" do
    plain = %(#main)
    I15R::PatternMatchers::Base.run(plain, "users.new").should == plain
  end  
end
