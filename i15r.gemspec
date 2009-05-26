# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{i15r}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["B\303\241lint \303\211rdi"]
  s.date = %q{2009-05-26}
  s.default_executable = %q{i15r}
  s.description = %q{The internationalizer. Replaces plain text strings in your views and replaces them with I18n message strings so you only have to provide the translations.}
  s.email = %q{balint.erdi@gmail.com}
  s.executables = ["i15r"]
  s.extra_rdoc_files = ["bin/i15r", "CHANGELOG", "lib/i15r.rb", "README.markdown", "tasks/i15r.rake"]
  s.files = ["bin/i15r", "CHANGELOG", "i15r.gemspec", "init.rb", "lib/i15r.rb", "Manifest", "MIT-LICENSE", "Rakefile", "README.markdown", "spec/i15r_spec.rb", "tasks/i15r.rake", "todos.markdown"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/balinterdi/i15r}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "I15r", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{i15r}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{The internationalizer. Replaces plain text strings in your views and replaces them with I18n message strings so you only have to provide the translations.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
