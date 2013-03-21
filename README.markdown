# I15r ![Build Status](https://api.travis-ci.org/balinterdi/i15r.png) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/balinterdi/i15r)

## Goal

You prefer polishing your views to manually replacing strings in them to make them i18n compatible.
If I got that one right, i15r is for you. It automates the process that would otherwise drive most of us nuts.

## Summary

I15r (Internationalizer) searches for all the non-i18n texts in your erb and haml templates in
the given file/directory and replaces them with I18n messages.

The message string is based on the path of the file in which the text was found and the text itself
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

## Installation

### Standalone

    gem install i15r

### In-app

Put the following in your Gemfile:

    gem 'i15r', '~> 0.5.1'

## Usage

### Convert a single file

    i15r path/leading/to/template

### Convert all files in a directory (deep search)

    i15r path/leading/to/directory

All files with an erb or haml suffix in that directory or somewhere in the hierarchy below will be converted.

### Dry run

By default, i15r overwrites all the source files with the i18n message strings it generates. If you first want to see what would be replaced, you should do:

    i15r app/views/users -n

or

    i15r app/views/users --dry-run

### Custom prefix

If you don't want the filename to appear in the i18n message string,
you can pass a prefix parameter that will be used to generate the message strings.
For example if you have the following in a file called app/views/users/new.html.erb:

    <label for="user-name">Name</label>
    <input type="text" id="user-name" name="user[name]" />

And then call:

    i15r app/views/users/new.html.erb --prefix my_project

The file will then contain:

    <label for="user-name"><%= I18n.t("my_project.name") %></label>
    <input type="text" id="user-name" name="user[name]" />

## Design principles & suggested use

I15R takes the 80-20 approach. It focuses on finding most of the text that needs
to be replaced in your templates and replacing them with the correct i18n strings.
It forgoes the 100% hit rate in favor of getting the 80% right and keeping the code
(relatively) simple. Consequently, please [report][issue_tracker] any bug that concerns
strings that should not have been replaced or ones that have been replaced incorrectly.

A good practice is to first run i15r with the --dry-run option to see what would be replaced
and then run it for real, without the --dry-run option. You can also run it on files that have
already been "internationalized" since i15r will just skip those rows.

### See also

Your next step is probably to create a YML locale file containing all the strings i15r generated. You're in luck! [missing_t][missing_t] is a gem that can do this for you.

## Contributing

Please submit any bugs or feature requests to the [issue tracker][issue_tracker].

If you'd like to contibute, please see [Contributing][contributing].

## License

Copyright (c) 2009 Balint Erdi

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[issue_tracker]: https://github.com/balinterdi/i15r/issues
[contributing]: https://github.com/balinterdi/i15r/blob/master/CONTRIBUTING.md
[missing_t]: https://github.com/balinterdi/missing_t
