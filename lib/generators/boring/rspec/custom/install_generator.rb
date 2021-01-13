module Boring
  module Rspec
    module Custom
      class InstallGenerator < Rails::Generators::Base
        desc "Adds rspec, factory_bot, and shoulda-matchers."
        source_root File.expand_path("templates", __dir__)

        class_option :version,
                     type: :string,
                     aliases: "-v",
                     desc: "Tell us the gem version which you want to use for the application"

        def add_testing_gems
          say "Adding testing gems", :green
          append_to_file "Gemfile", generate_gem_content

          # Surround in this block to prevent errors when gems are not installed locally
          # See: https://github.com/Shopify/shopify_app/pull/89
          Bundler.with_unbundled_env do
            run "bundle install"
          end
        end

        def add_boilerplate_file
          say "Adding boilerplate file", :green
          run "rails generate rspec:install"
        end

        def configure_rspec
          say "Configuring rspec", :green
          gsub_file("spec/spec_helper.rb", /=begin/, "")
          gsub_file("spec/spec_helper.rb", /=end/, "")

          content = <<~EOL
            \nDir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }\n
          EOL
          insert_into_file("spec/rails_helper.rb", content, before: "RSpec.configure do")
        end

        def configure_system_testing
          say "Add system testing configurations", :green
          template("better_rails_system_tests.rb", "spec/system/support/better_rails_system_tests.rb")
          template("capybara_setup.rb", "spec/system/support/capybara_setup.rb")
          template("cuprite_setup.rb", "spec/system/support/cuprite_setup.rb")
          template("precompile_assets.rb", "spec/system/support/precompile_assets.rb")
          template("system_helper.rb", "spec/system_helper.rb")
        end

        def add_rake_test_support
          say "Add rake testing support", :green
          template("rake.rb", "spec/support/shared_context/rake.rb")
        end

        def add_simplecov_configuration
          say "Adding simplecov configuration", :green
          prepend_to_file "spec/spec_helper.rb", simplecov_config
        end

        def configure_shoulda_matchers
          template("shoulda_matchers.rb", "spec/support/shoulda_matchers.rb")
        end

        def configure_factory_bot
          template("factory_bot.rb", "spec/support/factory_bot.rb")
        end

        private

        def generate_gem_content
          <<~RUBY

            group :test do
              gem "capybara"
              gem "cuprite"
            end

            group :development, :test do
              gem "factory_bot_rails"
              gem "rspec-rails"
              gem "shoulda-matchers"
              gem "simplecov"
              gem "simplecov-lcov"
            end
          RUBY
        end

        def simplecov_config
          <<~SIMPLECOV
            # frozen_string_literal: true
            
            if ENV["COVERAGE"]
              require 'simplecov'
              require "simplecov-lcov"

              SimpleCov.start 'rails' do
                if ENV["CI"]
                  SimpleCov::Formatter::LcovFormatter.config do |config|
                    config.report_with_single_file = true
                    config.lcov_file_name = "lcov.info"
                  end
                  formatter SimpleCov::Formatter::LcovFormatter
                else
                  SimpleCov::Formatter::HTMLFormatter
                end

                minimum_coverage 95
                maximum_coverage_drop 1

                # https://github.com/simplecov-ruby/simplecov#branch-coverage-ruby--25
                enable_coverage :branch

                min_line_count = proc { |source_file| source_file.lines.count < 11 }
                add_filter [min_line_count, /vendor/]

                add_group "Commands", "app/commands"
                add_group "Crons", "app/crons"
                add_group "Decorators", "app/decorators"
                add_group "Finders", "app/finders"
                add_group "Forms", "app/forms"
                add_group "Jobs", "app/jobs"
                add_group "Nulls", "app/nulls"
                add_group "Policies", "app/policies"
                add_group "Presenters", "app/presenters"
                add_group "Queries", "app/queries"
                add_group "Services", "app/services"
                add_group "Validators", "app/validators"
                add_group "Long files" do |file|
                  file.lines.count > 300
                end
              end
            end
          SIMPLECOV
        end
      end
    end
  end
end
