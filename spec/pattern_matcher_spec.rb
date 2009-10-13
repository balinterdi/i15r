require File.join(File.dirname(__FILE__), "..", "lib", "pattern_matcher")

require "spec"

describe I15R::PatternMatcher do
  it "should replace a link's title" do
    plain = %(Site root\nThis is it: <a title="site root" href="/"><img src="site_logo.png" /></a>)
    plain_rows, i18ned_rows = I15R::PatternMatcher.sub(plain, "users.new")

    plain_rows.should == ['This is it: <a title="site root" href="/"><img src="site_logo.png" /></a>']
    i18ned_rows.should == ['This is it: <a title="<%= I18n.t("users.new.site_root") %>" href="/"><img src="site_logo.png" /></a>']
  end
  
end
