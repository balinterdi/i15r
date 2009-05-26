# I15r

## Summary

I15r (Internationalizer) searches for all the non-i18n texts in erb views in the given files/directory and replaces them with I18n messages. The message string is based on the file in which the text was found and the text itself that was replaced. The script overwrites the file with the new content so to be on the safe side I advise to use a source code management (SCM) tool, like git.

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

## Installation

    gem install balinterdi-i15r --source http://gems.github.com
    
## Usage

To convert a file, all you need to do is

    i15r path/leading/to/view

Or

    i15r path/leading/to/directory
    
In this latter case, all files with an erb suffix will be converted.

## Licensing, contribution

The source code of this gem can be found at [http://github.com/balinterdi/i15r/](http://github.com/balinterdi/i15r/). It is released under the MIT-LICENSE, so you can basically do anything with it. However, if you think your modifications only make the tool better, and feel like it, please send a pull request or patch and I will probably merge in your changes. Any suggestions or feedback are welcome to <balint@bucionrails.com>.