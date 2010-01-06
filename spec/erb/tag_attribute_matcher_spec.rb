# encoding: UTF-8

require 'i15r/pattern_matcher'
require "spec"

# FIXME: since matcher blocks are added and executed in the Base class, that's what should be called
# in the tests. That's not elegant and tests are not independent: they are coupled through the Base's run method
describe I15R::PatternMatchers::Erb::TagAttributeMatcher do
  it "should replace a link's title" do
    plain = %(<a title="site root" href="/"><img src="site_logo.png" /></a>)
    i18ned = %(<a title="<%= I18n.t("users.new.site_root") %>" href="/"><img src="site_logo.png" /></a>)
    I15R::PatternMatchers::Erb::TagAttributeMatcher.run(plain, "users.new").should == i18ned
  end

  it "should replace a link's title that has non-english characters" do
    plain = %(<a title="raçine du site" href="/"><img src="site_logo.png" /></a>)
    i18ned = %(<a title="<%= I18n.t("users.new.raçine_du_site") %>" href="/"><img src="site_logo.png" /></a>)
    I15R::PatternMatchers::Erb::TagAttributeMatcher.run(plain, "users.new").should == i18ned
  end

end
