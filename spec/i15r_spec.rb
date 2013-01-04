# encoding: UTF-8
require 'spec_helper'
require 'i15r'

describe I15R do

  before do
    @i15r = I15R::Fixture.new
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
      #FIXME: Why should we deal only with Rails apps?
      path = "projects/doodle.rb"
      lambda { @i15r.file_path_to_message_prefix(path) }.should raise_error(I15R::AppFolderNotFound)
    end
  end

  describe "writing the changed file" do
    let(:path) { "app/views/users/new.html.erb" }
    let(:reader) { mock(:read => %Q{<label for="user-name">Name</label>}) }
    let(:writer) { mock("writer") }
    let(:printer) { mock("printer") }

    subject { I15R.new(reader, writer, printer) }

    specify do
      writer.should_receive(:write)
        .with(path, %Q{<label for="user-name"><%= I18n.t("users.new.name") %></label>\n})
      printer.should_receive(:print)
        .with(%Q{<label for="user-name">Name</label>},
              %Q{<label for="user-name"><%= I18n.t("users.new.name") %></label>})
      subject.internationalize_file(path)
    end
  end

  describe "generating the prefix" do
    let(:reader) { mock(:read => %Q{<label for="user-name">Name</label>}) }
    let(:writer) { mock("writer") }

    subject { I15R.new(reader, writer, I15R::NullPrinter.new) }

    describe "for a view" do
      let(:path) { "app/views/users/new.html.erb" }
      specify do
        writer.should_receive(:write).with(path, %Q{<label for="user-name"><%= I18n.t("users.new.name") %></label>\n})
        subject.internationalize_file(path)
      end
    end

    describe "for a partial" do
      let(:path) { "app/views/users/_badge.html.erb" }
      specify do
        writer.should_receive(:write).with(path, %Q{<label for="user-name"><%= I18n.t("users.badge.name") %></label>\n})
        subject.internationalize_file(path)
      end
    end

    describe "when there is an explicit prefix" do
      let(:path) { "app/views/users/_badge.html.erb" }

      subject { I15R.new(reader, writer, I15R::NullPrinter.new, :prefix => "nice") }

      specify do
        writer.should_receive(:write).with(path, %Q{<label for="user-name"><%= I18n.t("nice.name") %></label>\n})
        subject.internationalize_file(path)
      end
    end
  end

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

      @i15r.sub_plain_strings(plain_snippet, prefix_option, :erb).should == i18ned_snippet
    end
  end # "when an explicit prefix option was given"

end
