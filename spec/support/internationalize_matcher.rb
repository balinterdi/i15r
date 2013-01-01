RSpec::Matchers.define :internationalize do |non_i18n_string|
  chain :to do |i18n_string|
    @i18n_string = i18n_string
  end

  chain :to_the_same do
    @i18n_string = non_i18n_string
  end

  match do |pattern_matcher|
    @converted = pattern_matcher.run(non_i18n_string)
    @converted == @i18n_string
  end

  failure_message_for_should do |pattern_matcher|
    "#{non_i18n_string} was converted to
     #{@converted} but expected
     #{@i18n_string}"
  end
end
