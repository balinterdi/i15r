# encoding: UTF-8

require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe I15R::PatternMatchers::Haml::TagContentMatcher do
  it "should replace a tag's content where the tag is an implicit div" do
    plain = %(#form_head My account)
    i18ned = %(#form_head= I18n.t("users.edit.my_account"))
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.edit").should == i18ned
  end

  it "should replace a tag's content where the tag is an explicit one" do
    plain = %(%p Please check your inbox and click on the activation link.)
    i18ned = %(%p= I18n.t("users.show.please_check_your_inbox_and_click_on_the_activation_link"))
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

  it "should not replace a line with just an hmtl tag and no text" do
    plain = "%p"
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == plain
  end

  it "should not include the %tag in the generated message string" do
    plain = "%h2 Resend unlock instructions"
    i18ned = %(%h2= I18n.t("users.new.resend_unlock_instructions"))
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  describe "when text has non-english characters" do
    it "should replace a tag's content where the tag is an implicit div" do
      plain = %(#form_head Türkçe)
      i18ned = %(#form_head= I18n.t("users.edit.türkçe"))
      I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.edit").should == i18ned
    end

    it "should replace a tag's content where the tag is an explicit one" do
      plain = %(%p Egy, kettő, három, négy, öt.)
      i18ned = %(%p= I18n.t("users.show.egy_kettő_három_négy_öt"))
      I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.show").should == i18ned
    end

  #1.8fail
    it "should replace a tag's content which is simple text all by itself on a line" do
      plain = %(Türkçe)
      i18ned = %(= I18n.t("users.new.türkçe"))
      I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == i18ned
    end
  end
end
