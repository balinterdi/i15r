require 'i15r/pattern_matcher'
require "spec"

# FIXME: since matcher blocks are added and executed in the Base class, 
# tests are not independent: they are coupled through the Base's run method
describe I15R::PatternMatchers::Erb::RailsHelperMatcher do
  it "should replace a title in a link_to helper" do
    plain = %(<p class="highlighted"><%= link_to 'New user', new_user_path %>?</p>)
    i18ned = %(<p class="highlighted"><%= link_to I18n.t("users.index.new_user"), new_user_path %>?</p>)
    I15R::PatternMatchers::Erb::RailsHelperMatcher.run(plain, "users.index").should == i18ned
  end

  it "should replace a title in a link_to helper with html attributes" do
    plain = %(<p><%= link_to "Create a new user", new_user_path, { :class => "add" } -%></p>)
    i18ned = %(<p><%= link_to I18n.t("users.index.create_a_new_user"), new_user_path, { :class => "add" } -%></p>)
    I15R::PatternMatchers::Erb::RailsHelperMatcher.run(plain, "users.index").should == i18ned
  end
  
  it "should replace the label text in a label helper" do
    plain = %(<%= f.label :name, "Name" %>)
    i18ned = %(<%= f.label :name, I18n.t("users.new.name") %>)
    I15R::PatternMatchers::Erb::RailsHelperMatcher.run(plain, "users.new").should == i18ned
  end
  
  it "should replace the label text of a label_tag helper" do
    plain = %(<%= label_tag :name, "Name" %>)
    i18ned = %(<%= label_tag :name, I18n.t("users.new.name") %>)
    I15R::PatternMatchers::Erb::RailsHelperMatcher.run(plain, "users.new").should == i18ned
  end
  
  it "should replace the title of a submit helper in a form builder" do
    plain = %(<%= f.submit "Create user" %>)
    i18ned = %(<%= f.submit I18n.t("users.new.create_user") %>)
    I15R::PatternMatchers::Erb::RailsHelperMatcher.run(plain, "users.new").should == i18ned
  end

  it "should replace the title of a submit_tag helper" do
    plain = %(<%= submit_tag "Create user" %>)
    i18ned = %(<%= submit_tag I18n.t("users.new.create_user") %>)
    I15R::PatternMatchers::Erb::RailsHelperMatcher.run(plain, "users.new").should == i18ned
  end

end
