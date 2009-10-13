### 0.1

* DONE bug: In messages ending in punctuation (e.g No tags.) the punctuation is removed when replaced (e.g <%= I18n.t("users.show.no_tags") %>)

### 0.1.1

* DONE bug: indenting whitespace is removed around replaced messages
This is easy to fix, the whitespace has to be readded just like the punctuation

    <% tags = @photo.tag_list %>
      Tags:
    <% if !tags.blank? %>

    becomes

    <% tags = @photo.tag_list %><%= I18n.t("mysite.tags") %><% if !tags.blank? %>

### 0.2

* DONE title of links have to be internationailzed, e.g: <a title="Go back" href="...">
* DONE <%= f.label :body, "Question" %>
* DONE <%= label_tag :body, "Question" %>
* DONE <%= f.submit "Submit question" %>
* DONE <%= submit_tag "Submit question" %>
* DONE think about which rails helpers could be given text that needs to be internationalized (currently only link_to is scanned)
* DONE suppress printing of yaml strings (change by Alberto) when running the specs
* DONE make it possible to run i15r on several files

### 0.?

* dry-run option: only show the diffs but do not actually overwrite the files
* make prefix not replace the inferred message string prefix, but really act as a prefix. (e.g if anetcom is given as a prefix, and the inferred message string is 'users.new' it should not be 'anetcom.name', but 'anetcom.users.new.name')
* handle non-ascii characters properly (UTF-8 support) when replacing them. Mañana should become I18n.t("prefix.manana"), for instance. That is, regular expressions should be utf-8 aware.
* write the necessary i18n strings back into the yaml file
* make interactive mode possible. the user is asked about each message to be replaced. he can choose to replace it, skip it or even edit it. Ideally the message would be shown in its context.

