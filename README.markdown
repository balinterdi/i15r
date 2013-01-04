# I15r ![Build Status](https://api.travis-ci.org/balinterdi/i15r.png)


## Summary

I15r (Internationalizer) searches for all the non-i18n texts in your views in
the given files/directory and replaces them with I18n messages. The message
string is based on the file in which the text was found and the text itself
that was replaced.

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

It can process erb and haml files.

## Installation

    gem install i15r

or put the following in your Gemfile:

   gem 'i15r', '~> 0.4.4'

## Usage

### Convert a single file

    i15r path/leading/to/view

### Convert all files in a directory (deep search)

    i15r path/leading/to/directory

All files with an erb or haml suffix in that directory or somewhere in the hierarchy below will be converted.

### Dry run

By default, i15r overwrites all the source files with the i18n message strings it generates. If you first want to see what would be replaced, you should do:

    i15r app/views/users -p

or

    i15r app/views/users --pretend

### Custom prefix

If you don't want the filename to appear in the i18n message string, you can pass a prefix parameter that will be used to generate the message strings. For example if you have the following in a file called app/views/users/new.html.erb:

    <label for="user-name">Name</label>
    <input type="text" id="user-name" name="user[name]" />

And then call:

    i15r app/views/users/new.html.erb --prefix my_project

The file will then contain:

    <label for="user-name"><%= I18n.t("my_project.name") %></label>
    <input type="text" id="user-name" name="user[name]" />

## Disclaimer (sort of)

Please note that this is an early version mainly built up of examples I've come
through doing client work. I am pretty sure there are a number of cases which
i15r -at the moment- does not handle well (or at all). If you find such an
example, please [let me know][issue_tracker] or if you feel motivated, submit a
patch. Oh, yes, to prevent unwanted changes to your view files, you should use
a SCM (that goes without saying, of course) and probably use the --pretend
option.

[issue_tracker]: http://github.com/balinterdi/i15r/issues

## Licensing, contribution

The source code of this gem can be found at
[http://github.com/balinterdi/i15r/](http://github.com/balinterdi/i15r/). It is
released under the MIT-LICENSE, so you can basically do anything with it.
However, if you think your modifications only make the tool better, please send
a pull request or patch and I will consider merging in your changes. Any
suggestions or feedback are welcome to <balint@balinterdi.com>.
