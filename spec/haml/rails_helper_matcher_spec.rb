# encoding: UTF-8

require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe I15R::PatternMatchers::Haml::RailsHelperMatcher do
  it "should replace a title in a link_to helper in a %tag row" do
    plain = %(%p= link_to 'New user', new_user_path)
    i18ned = %(%p= link_to I18n.t("users.index.new_user"), new_user_path)
    I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.index").should == i18ned
  end

  it "should replace a title in a link_to helper in an implicit div row" do
    plain = %(#new_user_link= link_to 'New user', new_user_path)
    i18ned = %(#new_user_link= link_to I18n.t("users.index.new_user"), new_user_path)
    I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.index").should == i18ned
  end

  it "should replace the label text in a label helper" do
    plain = %(= f.label :password, "Password")
    i18ned = %(= f.label :password, I18n.t("users.new.password"))
    I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i18ned
  end

  it "should preserve whitespace when replacing a label helper" do
    plain = %(             = f.label :password, "Password")
    i18ned = %(             = f.label :password, I18n.t("users.new.password"))
    I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i18ned
  end

  it "should replace a title in a link_to helper that uses parens and other text in the same row in an implicit div row" do
    plain = %q(= "I accept the #{link_to('terms and conditions', terms_and_conditions_path)}")
    i15d = %q(= I18n.t("users.new.i_accept_the", :link => link_to(I18n.t("users.new.terms_and_conditions"), terms_and_conditions_path)))
    I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i15d
  end

  it "should replace a title in a link_to helper that does not use parens and other text in the same row in an implicit div row" do
    plain = %q(= "I accept the #{link_to 'terms and conditions', terms_and_conditions_path}")
    i15d = %q(= I18n.t("users.new.i_accept_the", :link => link_to(I18n.t("users.new.terms_and_conditions"), terms_and_conditions_path)))
    I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i15d
  end
  
  it "should replace a title in a link_to helper that uses the haml == operator" do
    plain = %q(== I accept the #{link_to('terms and conditions', terms_and_conditions_path)})
    i15d = %q(== I18n.t("users.new.i_accept_the", :link => link_to(I18n.t("users.new.terms_and_conditions"), terms_and_conditions_path)))
    I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i15d
  end
  
  describe "when text has non-english characters" do
    it "should replace a title in a link_to helper in a %tag row" do
      plain = %(%p= link_to 'Új felhasználó', new_user_path)
      i18ned = %(%p= link_to I18n.t("users.index.Új_felhasználó"), new_user_path)
      I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.index").should == i18ned
    end

    it "should replace a title in a link_to helper in an implicit div row" do
      plain = %(#new_user_link= link_to 'Új felhasználó', new_user_path)
      i18ned = %(#new_user_link= link_to I18n.t("users.index.Új_felhasználó"), new_user_path)
      I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.index").should == i18ned
    end

    it "should replace the label text in a label helper" do
      plain = %(= f.label :password, "Contraseña")
      i18ned = %(= f.label :password, I18n.t("users.new.contraseña"))
      I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i18ned
    end

    it "should preserve whitespace when replacing a label helper" do
      plain = %(             = f.label :password, "Contraseña")
      i18ned = %(             = f.label :password, I18n.t("users.new.contraseña"))
      I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i18ned
    end

    it "should replace a title in a link_to helper that uses parens and other text in the same row in an implicit div row" do
      plain = %q(= "Elfőgadom a #{link_to('feltételeket', terms_and_conditions_path)}")
      i15d = %q(= I18n.t("users.new.elfőgadom_a", :link => link_to(I18n.t("users.new.feltételeket"), terms_and_conditions_path)))
      I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i15d
    end

    it "should replace a title in a link_to helper that does not use parens and other text in the same row in an implicit div row" do
      plain = %q(= "Elfőgadom a #{link_to 'feltételeket', terms_and_conditions_path}")
      i15d = %q(= I18n.t("users.new.elfőgadom_a", :link => link_to(I18n.t("users.new.feltételeket"), terms_and_conditions_path)))
      I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i15d
    end

    it "should replace a title in a link_to helper that uses the haml == operator" do
      plain = %q(== Elfőgadom a #{link_to('feltételeket', terms_and_conditions_path)})
      i15d = %q(== I18n.t("users.new.elfőgadom_a", :link => link_to(I18n.t("users.new.feltételeket"), terms_and_conditions_path)))
      I15R::PatternMatchers::Haml::RailsHelperMatcher.run(plain, "users.new").should == i15d
    end
  end

end