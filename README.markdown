# I15r

I20r (Internationalizer) searches for all the non-i18n texts in the given files/directory and replaces them with I18n messages based on the file in which they were found and of course the text itself that was replaced. Optional arguments are also taken into account.

E.g

    (in file app/views/users/new.html.erb)
    <label for="user-name">Name</label>
    <input type="text" id="user-name" name="user[name]" />
    
will be replaced by:

    (in file app/views/users/new.html.erb)
    <label for="user-name"><%= I18n.t("users.new.name") %></label>
    <input type="text" id="user-name" name="user[name]" />
    
and 

    (in file app/views/member/users/edit.html.erb)
    <label for="user-name">Name</label>
    <input type="text" id="user-name" name="user[name]" />
    
will be replaced by

    (in file app/views/member/users/edit.html.erb)
    <label for="user-name"><%= I18n.t("member.users.edit.name") %></label>
    <input type="text" id="user-name" name="user[name]" />
    
Unless -y is given, the user will be prompted to confirm each substitution.