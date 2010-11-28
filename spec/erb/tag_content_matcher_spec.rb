# encoding: UTF-8

require 'i15r/pattern_matcher'
require "spec"

describe I15R::PatternMatchers::Erb::TagContentMatcher do

  it "should replace a single word" do
    plain = %(<label for="user-name">Name</label>)
    i18ned = %(<label for="user-name"><%= I18n.t("users.new.name") %></label>)
    I15R::PatternMatchers::Erb::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  it "should replace several words" do
    plain = %(<label for="user-name">Earlier names</label>)
    i18ned = %(<label for="user-name"><%= I18n.t("users.new.earlier_names") %></label>)
    I15R::PatternMatchers::Erb::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  it "should remove punctuation from plain strings" do
    plain = %(<label for="user-name">Got friends? A friend's name</label>)
    i18ned = %(<label for="user-name"><%= I18n.t("users.new.got_friends_a_friends_name") %></label>)
    I15R::PatternMatchers::Erb::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  it "should not remove punctuation outside plain strings" do
    plain = %(<label for="user-name">A friend's name:</label>)
    i18ned = %(<label for="user-name"><%= I18n.t("users.new.a_friends_name") %>:</label>)
    I15R::PatternMatchers::Erb::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  it "should preserve whitespace in the content part of the tag" do
    plain = %(<label for="user-name"> Name </label>)
    i18ned = %(<label for="user-name"> <%= I18n.t("users.new.name") %> </label>)
    I15R::PatternMatchers::Erb::TagContentMatcher.run(plain, "users.new").should == i18ned
  end
  
  #1.8fail
  it "should replace a word with non-ascii characters" do
    plain = %(<label for="when">Mañana</label>)
    i18ned = %(<label for="when"><%= I18n.t("users.new.mañana") %></label>)
    I15R::PatternMatchers::Erb::TagContentMatcher.run(plain, "users.new").should == i18ned    
  end

end