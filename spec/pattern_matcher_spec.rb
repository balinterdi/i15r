# encoding: UTF-8
require 'spec_helper'
require 'i15r/pattern_matcher'

describe I15R::PatternMatcher do
  describe "in erb templates" do
    let(:pattern_matcher) { I15R::PatternMatcher.new("users.new", :erb) }

    describe "in tag content" do
      it "replaces a single word in a label" do
        _in = %(<label for="user-name">Name</label>)
        out = %(<label for="user-name"><%= I18n.t("users.new.name") %></label>)
        pattern_matcher.run(_in).should == out
      end

      it "replaces several words in a label" do
        _in = %(<label for="user-name">First name</label>)
        out = %(<label for="user-name"><%= I18n.t("users.new.first_name") %></label>)
        pattern_matcher.run(_in).should == out
      end

      it "removes punctuation from plain strings" do
        _in = %(<label for="user-name">Got friends? A friend's name</label>)
        out = %(<label for="user-name"><%= I18n.t("users.new.got_friends_a_friends_name") %></label>)
        pattern_matcher.run(_in).should == out
      end

      it "does not remove punctuation outside plain strings" do
        #TODO: decice whether stripping the punctuation from the tag content is admissible.
        # Not stripping it would mean overly complex regular expressions, probably.
        _in = %(<label for="user-name">A friend's name:</label>)
        out = %(<label for="user-name"><%= I18n.t("users.new.a_friends_name") %></label>)
        pattern_matcher.run(_in).should == out
      end

      it "does not preserve whitespace in the content part of the tag" do
        _in = %(<label for="user-name"> Name </label>)
        out = %(<label for="user-name"><%= I18n.t("users.new.name") %></label>)
        pattern_matcher.run(_in).should == out
      end

      it "replaces a word with non-ascii characters" do
        _in = %(<label for="when">Mañana</label>)
        out = %(<label for="when"><%= I18n.t("users.new.mañana") %></label>)
        pattern_matcher.run(_in).should == out
      end
    end

    describe "in tag attributes" do
      it "correctly replaces both strings on the same line" do
        _in = %(This is it: <a title="site root" href="/"><img src="site_logo.png" /></a>)
        out = %(<%= I18n.t("users.new.this_is_it") %><a title="<%= I18n.t("users.new.site_root") %>" href="/"><img src="site_logo.png" /></a>)
        pattern_matcher.run(_in).should == out
      end

      it "replaces both strings on the same line that have non-ascii chars" do
        _in = %(C'est ça: <a title="site root" href="/"><img src="site_logo.png" /></a>)
        out = %(<%= I18n.t("users.new.cest_ça") %><a title="<%= I18n.t("users.new.site_root") %>" href="/"><img src="site_logo.png" /></a>)
        pattern_matcher.run(_in).should == out
      end
    end

    describe "Rails helper methods" do
      let(:pattern_matcher) { I15R::PatternMatcher.new("users.index", :erb) }
      it "replaces a title in a link_to helper" do
        _in = %(<p class="highlighted"><%= link_to 'New user', new_user_path %>?</p>)
        out = %(<p class="highlighted"><%= link_to I18n.t("users.index.new_user"), new_user_path %>?</p>)
        pattern_matcher.run(_in).should == out
      end

      it "replaces a title in a link_to helper with html attributes" do
        _in = %(<p><%= link_to "Create a new user", new_user_path, { :class => "add" } -%></p>)
        out = %(<p><%= link_to I18n.t("users.index.create_a_new_user"), new_user_path, { :class => "add" } -%></p>)
        pattern_matcher.run(_in).should == out
      end

      it "replaces the label text in a label helper" do
        _in = %(<%= f.label :name, "Name" %>)
        out = %(<%= f.label :name, I18n.t("users.index.name") %>)
        pattern_matcher.run(_in).should == out
      end

      it "replaces the title of a submit helper in a form builder" do
        _in = %(<%= f.submit "Create user" %>)
        out = %(<%= f.submit I18n.t("users.index.create_user") %>)
        pattern_matcher.run(_in).should == out
      end

      it "replaces the title of a submit_tag helper" do
        _in = %(<%= submit_tag "Create user" %>)
        out = %(<%= submit_tag I18n.t("users.index.create_user") %>)
        pattern_matcher.run(_in).should == out
      end

      describe "when text has non-ascii characters" do
        it "replaces a title in a link_to helper" do
          _in = %(<p class="highlighted"><%= link_to 'Új felhasználó', new_user_path %>?</p>)
          out = %(<p class="highlighted"><%= link_to I18n.t("users.index.Új_felhasználó"), new_user_path %>?</p>)
          pattern_matcher.run(_in).should == out
        end

        it "replaces a title in a link_to helper with html attributes" do
          _in = %(<p><%= link_to "Új felhasználó létrehozása", new_user_path, { :class => "add" } -%></p>)
          out = %(<p><%= link_to I18n.t("users.index.Új_felhasználó_létrehozása"), new_user_path, { :class => "add" } -%></p>)
          pattern_matcher.run(_in).should == out
        end

        it "replaces the label text in a label helper" do
          _in = %(<%= f.label :name, "Név" %>)
          out = %(<%= f.label :name, I18n.t("users.index.név") %>)
          pattern_matcher.run(_in).should == out
        end

        it "replaces the label text in a label_tag helper" do
          _in = %(<%= label_tag :name, "Név" %>)
          out = %(<%= label_tag :name, I18n.t("users.index.név") %>)
          pattern_matcher.run(_in).should == out
        end

        it "replaces the title of a submit helper in a form builder" do
          _in = %(<%= f.submit "Új felhasználó" %>)
          out = %(<%= f.submit I18n.t("users.index.Új_felhasználó") %>)
          pattern_matcher.run(_in).should == out
        end

        it "replaces the title of a submit_tag helper" do
          _in = %(<%= submit_tag "Új felhasználó" %>)
          out = %(<%= submit_tag I18n.t("users.index.Új_felhasználó") %>)
          pattern_matcher.run(_in).should == out
        end

      end
    end
  end

  describe "in haml templates" do
    let(:pattern_matcher) { I15R::PatternMatcher.new("users.show", :haml) }

    it "does not replace a simple haml div tag with an id" do
      _in = %(#main)
      pattern_matcher.run(_in).should == _in
    end

    it "replaces a tag's content where the tag is an implicit div" do
      _in = %(#form_head My account)
      out = %(#form_head= I18n.t("users.show.my_account"))
      pattern_matcher.run(_in).should == out
    end

    it "replaces a tag's content where the tag is an explicit one" do
      _in = %(%p Please check your inbox and click on the activation link.)
      out = %(%p= I18n.t("users.show.please_check_your_inbox_and_click_on_the_activation_link"))
      pattern_matcher.run(_in).should == out
    end

    it "replaces a tag's content which is simple text all by itself on a line" do
      _in = %(please visit)
      out = %(= I18n.t("users.show.please_visit"))
      pattern_matcher.run(_in).should == out
    end

  end
end
