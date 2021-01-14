# frozen_string_literal: true

module Boring
  module Rubocop
    class InstallGenerator < Rails::Generators::Base
      desc "Adds rubocop to the application"
      source_root File.expand_path("templates", __dir__)

      DEFAULT_RUBY_VERSION = "2.7.1"

      class_option :ruby_version,
                   type: :string,
                   aliases: "-v",
                   desc:
                     "Tell us the ruby version which you use for the application. Default to Ruby #{
                       DEFAULT_RUBY_VERSION
                     }"

      def add_rubocop_gems
        say "Adding rubocop gems", :green
        rubocop_gem_content = <<~RUBY

          \tgem "rubocop",  require: false
          \tgem "rubocop-rails",  require: false
          \tgem "rubocop-rspec", require: false
          \tgem "rubocop-performance", require: false
        RUBY
        insert_into_file "Gemfile", rubocop_gem_content, after: /group :development do/

        # Surround with_unbundled_env to prevent errors when gems are not installed locally
        # See: https://github.com/Shopify/shopify_app/pull/89
        Bundler.with_unbundled_env { run "bundle install" }
      end

      def add_rails_prefered_rubocop_rules
        say "Adding rubocop style guides", :green
        @target_ruby_version =
          options[:ruby_version] ? options[:ruby_version] : DEFAULT_RUBY_VERSION
        template(".rubocop.yml", ".rubocop.yml")
      end
    end
  end
end
