require File.join(File.dirname(__FILE__), "..", "lib", "i20r")
require "mocha"
require "spec"

# use mocha for mocking instead of
# Rspec's own mock framework
Spec::Runner.configure do |config|
  config.mock_with :mocha
end

describe "I20r" do
  before do
    @i20r = I20r.new
  end

  describe "message text replacement" do
    before do
      
    end

    it "should correctly turn file paths to message prefixes" do
      @i20r.file_path_to_message_prefix("/app/views/users/new.html.erb").should == "users.new"
    end

    it "should replace a plain text snippet with a message derived from the text and a prefix" do
      @i20r.get_i18n_message_string("Name", "users.new").should == "users.new.name"
    end
    
    describe "in files" do
      before do
        @file_path = '/app/views/users/new.html.erb'
        message_prefix = "users.new"
        @i20r.expects(:file_path_to_message_prefix).with(@file_path).returns(message_prefix)

        @plain_snippet = <<-EOS
          <label for="user-name">Name</label>
          <input type="text" id="user-name" name="user[name]" />
        EOS
        @i18ned_snippet = <<-EOS
          <label for="user-name"><%= I18n.t("#{message_prefix}.name") %></label>
          <input type="text" id="user-name" name="user[name]" />
        EOS

        @i20r.expects(:get_content_from).with(@file_path).returns(@plain_snippet)        
      end
      it "should correctly replace plain texts with I18n-ed messages" do
        @i20r.replace_non_i18_messages(@file_path).should == @i18ned_snippet
      end
    end

  end

end