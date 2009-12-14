require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe I15R::PatternMatchers::Haml::TagContentMatcher do
  it "should replace a tag's content where the tag is an implicit div" do
    plain = %(#form_head My account)
    i18ned = %(#form_head= I18n.t("users.edit.my_account"))
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.edit").should == i18ned
  end

  it "should replace a tag's content where the tag is an explicit one" do
    plain = %(%p Please check your inbox and click on the activation link.)
    i18ned = %(%p I18n.t("users.show.please_check_your_inbox_and_click_on_the_activation_link"))
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.show").should == i18ned
  end

  it "should replace a tag's content which is simple text all by itself on a line" do
    plain = %(please visit)
    i18ned = %(= I18n.t("users.new.please_visit"))
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  it "should not replace an implict div with an assigned class" do
    plain = %(        .field)
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == plain
  end
end