source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.4"

gem "rails",           "7.0.4.3"
gem "sassc-rails",     "2.1.2"
gem "sprockets-rails", "3.4.2"
gem "importmap-rails", "1.1.5"
gem "turbo-rails",     "1.4.0"
gem "stimulus-rails",  "1.2.1"
gem "jbuilder",        "2.11.5"
gem "puma",            "5.6.8"
gem "bootsnap",        "1.16.0", require: false
gem "sqlite3",         "1.6.1"
gem "selenium-webdriver"
gem "webdrivers",         "5.2.0"
gem 'pg'
gem "capybara",                 "3.38.0"
gem 'ruby-openai' # 'ruby-openai'ではなく'openai'に統一

group :development, :test do
  gem "debug",   "1.7.1", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "web-console",         "4.2.0"
  gem "solargraph",          "0.50.0"
  gem "irb",                 "1.10.0"
  gem "repl_type_completor", "0.1.2"
end

group :test do
  gem "rails-controller-testing", "1.0.5"
  gem "minitest",                 "5.18.0"
  gem "minitest-reporters",       "1.6.0"
  gem "guard",                    "2.18.0"
  gem "guard-minitest",           "2.4.6"
end
