# I15r

## Summary

I15r (Internationalizer) searches for all the non-i18n texts in erb views in the given files/directory and replaces them with I18n messages. The message string is based on the file in which the text was found and the text itself that was replaced. 

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

    gem install i15r --source http://gemcutter.org
    
## Usage

### Convert a single file

    i15r path/leading/to/view

### Convert all files in a directory (deep search)

    i15r path/leading/to/directory
    
All files with an erb suffix will be converted.

### Dry run

By default, i15r overwrites all the source files with the i18n message strings it generates. If you first want to see what would be replaced, you should do:

    i15r app/views/users -p

## Licensing, contribution

The source code of this gem can be found at [http://github.com/balinterdi/i15r/](http://github.com/balinterdi/i15r/). It is released under the MIT-LICENSE, so you can basically do anything with it. However, if you think your modifications only make the tool better, please send a pull request or patch and I will consider merging in your changes. Any suggestions or feedback are welcome to <balint@bucionrails.com>.