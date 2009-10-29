# puts %(#{File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib", "i15r")})
$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib")

require "i15r"
require "fakefs"

$testing = true

describe I15R::Base do

  before do
    @i15r = I15R::Base.new
  end

  describe "converting file paths to message prefixes" do

    it "should correctly work from app root for views" do
      @i15r.file_path_to_message_prefix("app/views/users/new.html.erb").should == "users.new"
    end

    it "should correctly work from app root for helpers" do
      @i15r.file_path_to_message_prefix("app/helpers/users_helper.rb").should == "users_helper"
    end

    it "should correctly work from app root for controllers" do
      @i15r.file_path_to_message_prefix("app/controllers/users_controller.rb").should == "users_controller"
    end

    it "should correctly work from app root for models" do
      @i15r.file_path_to_message_prefix("app/models/user.rb").should == "user"
    end

    it "should correctly work from app root for deep dir. structures" do
      @i15r.file_path_to_message_prefix("app/views/member/session/users/new.html.erb").should == "member.session.users.new"
    end

    it "should raise if path does not contain any Rails app directories" do
      path = "projects/doodle.rb"
      lambda { @i15r.file_path_to_message_prefix(path) }.should raise_error(AppFolderNotFound)
    end

  end

  describe "turning plain messages into i18n message strings" do

    it "should downcase a single word" do
      I15R::Base.get_i18n_message_string("Name", "users.new").should == "users.new.name"
    end

    it "should replace spaces with underscores" do
      I15R::Base.get_i18n_message_string("New name", "users.index").should == "users.index.new_name"
    end

  end

  describe "when substituting the plain contents with i18n message strings" do
    before do
      @i15r.options.prefix = nil
      @file_path = "app/views/users/new.html.erb"
      File.open(@file_path, "w") { |f| f.write("<label for=\"user-name\">Name</label>") }
    end

    describe "and in dry-run mode" do
      before do
        @i15r.stub!(:dry_run?).and_return(true)
      end
      it "should not touch any files" do
        @i15r.should_not_receive(:write_content_to)
        @i15r.internationalize_file(@file_path)
      end
      it "should display the diff" do
        @i15r.should_receive(:show_diff)
        @i15r.internationalize_file(@file_path)
      end
    end

    describe "and not in dry-run mode" do
      before do
        @i15r.stub!(:dry_run?).and_return(false)
      end
      it "should write the files" do
        @i15r.should_receive(:write_content_to)
        @i15r.internationalize_file(@file_path)
      end
    end
  end

  describe "when no prefix option was given" do
    it "should correctly internationalize messages using a prefix derived from the path" do
      message_prefix = "users.new"
      plain_snippet = <<-EOS
        <label for="user-name">Name</label>
        <input type="text" id="user-name" name="user[name]" />
      EOS
      i18ned_snippet = <<-EOS
        <label for="user-name"><%= I18n.t("#{message_prefix}.name") %></label>
        <input type="text" id="user-name" name="user[name]" />
      EOS
      @i15r.sub_plain_strings(plain_snippet, message_prefix).should == i18ned_snippet
    end
  end # "when no prefix option was given"

  describe "when an explicit prefix option was given" do
    it "should correctly internationalize messages using the prefix" do
      prefix_option = "mysite"
      plain_snippet = <<-EOS
        <label for="user-name">Name</label>
        <input type="text" id="user-name" name="user[name]" />
      EOS
      i18ned_snippet = <<-EOS
        <label for="user-name"><%= I18n.t("#{prefix_option}.name") %></label>
        <input type="text" id="user-name" name="user[name]" />
      EOS

      @i15r.sub_plain_strings(plain_snippet, prefix_option).should == i18ned_snippet
    end

  end # "when an explicit prefix option was given"

end