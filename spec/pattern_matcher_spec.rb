# encoding: UTF-8
require 'spec_helper'
require 'i15r/pattern_matcher'

describe I15R::PatternMatcher do

  subject { pattern_matcher }

  describe "in erb templates" do
    let(:pattern_matcher) { I15R::PatternMatcher.new("users.new", :erb) }

    describe "in tag content" do
      it { should internationalize(%(<label for="user-name">Name</label>))
                             .to(%(<label for="user-name"><%= I18n.t("users.new.name") %></label>)) }

      it { should internationalize(%(<label for="user-name">First name</label>))
                             .to(%(<label for="user-name"><%= I18n.t("users.new.first_name") %></label>)) }

      it { should internationalize(%(<label for="user-name">Got friends? A friend's name</label>))
                             .to(%(<label for="user-name"><%= I18n.t("users.new.got_friends_a_friends_name") %></label>)) }

      it { should internationalize(%(<label for="user-name">A friend's name:</label>))
                             .to(%(<label for="user-name"><%= I18n.t("users.new.a_friends_name") %></label>)) }

      it { should internationalize(%(<label for="user-name"> Name </label>))
                             .to(%(<label for="user-name"><%= I18n.t("users.new.name") %></label>)) }

      it { should internationalize(%(<label for="when">Mañana</label>))
                             .to(%(<label for="when"><%= I18n.t("users.new.mañana") %></label>)) }
    end

    describe "in tag attributes" do
      it { should internationalize(%(This is it: <a title="site root" href="/"><img src="site_logo.png" /></a>))
                             .to(%(<%= I18n.t("users.new.this_is_it") %><a title="<%= I18n.t("users.new.site_root") %>" href="/"><img src="site_logo.png" /></a>)) }

      it { should internationalize(%(C'est ça: <a title="site root" href="/"><img src="site_logo.png" /></a>))
                             .to(%(<%= I18n.t("users.new.cest_ça") %><a title="<%= I18n.t("users.new.site_root") %>" href="/"><img src="site_logo.png" /></a>)) }
    end

    describe "Rails helper methods" do
      let(:pattern_matcher) { I15R::PatternMatcher.new("users.index", :erb) }

      it { should internationalize(%(<p class="highlighted"><%= link_to 'New user', new_user_path %>?</p>))
                             .to(%(<p class="highlighted"><%= link_to I18n.t("users.index.new_user"), new_user_path %>?</p>)) }

      it { should internationalize(%(<p><%= link_to "Create a new user", new_user_path, { :class => "add" } -%></p>))
                             .to(%(<p><%= link_to I18n.t("users.index.create_a_new_user"), new_user_path, { :class => "add" } -%></p>)) }

      it { should internationalize(%(<%= f.label :name, "Name" %>))
                             .to(%(<%= f.label :name, I18n.t("users.index.name") %>)) }

      it { should internationalize(%(<%= f.submit "Create user" %>))
                             .to(%(<%= f.submit I18n.t("users.index.create_user") %>)) }

      it { should internationalize(%(<%= submit_tag "Create user" %>))
                             .to(%(<%= submit_tag I18n.t("users.index.create_user") %>)) }

      describe "when text has non-ascii characters" do
        it { should internationalize(%(<p class="highlighted"><%= link_to 'Új felhasználó', new_user_path %>?</p>))
                               .to(%(<p class="highlighted"><%= link_to I18n.t("users.index.Új_felhasználó"), new_user_path %>?</p>)) }

        it { should internationalize(%(<p><%= link_to "Új felhasználó létrehozása", new_user_path, { :class => "add" } -%></p>))
                               .to(%(<p><%= link_to I18n.t("users.index.Új_felhasználó_létrehozása"), new_user_path, { :class => "add" } -%></p>)) }

        it { should internationalize(%(<%= f.label :name, "Név" %>))
                               .to(%(<%= f.label :name, I18n.t("users.index.név") %>)) }

        it { should internationalize(%(<%= label_tag :name, "Név" %>))
                               .to(%(<%= label_tag :name, I18n.t("users.index.név") %>)) }

        it { should internationalize(%(<%= f.submit "Új felhasználó" %>))
                               .to(%(<%= f.submit I18n.t("users.index.Új_felhasználó") %>)) }

        it { should internationalize(%(<%= submit_tag "Új felhasználó" %>))
                               .to(%(<%= submit_tag I18n.t("users.index.Új_felhasználó") %>)) }
      end
    end
  end

  describe "in haml templates" do
    let(:pattern_matcher) { I15R::PatternMatcher.new("users.show", :haml) }

    it { should internationalize(%(#main)).to(%(#main)) }

    it { should internationalize(%(#form_head My account))
                           .to(%(#form_head= I18n.t("users.show.my_account"))) }

    it { should internationalize(%(%p Please check your inbox and click on the activation link.))
                           .to(%(%p= I18n.t("users.show.please_check_your_inbox_and_click_on_the_activation_link"))) }

    it { should internationalize("please visit").to('= I18n.t("users.show.please_visit")') }
    it { should internationalize("Mañana").to('= I18n.t("users.show.mañana")') }
    it { should internationalize("C'est ça").to('= I18n.t("users.show.cest_ça")') }
  end

end
