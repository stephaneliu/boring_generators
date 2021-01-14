module Boring
  module Guard
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Guard with friends"
      source_root File.expand_path("templates", __dir__)

      def add_guard_gems
        say "Adding guard gems", :green
        guard_gems = <<~RUBY

          \tgem "guard-brakeman", require: false
          \tgem "guard-haml_lint"
          \tgem "guard-livereload", require: false
          \tgem "guard-process"
          \tgem "guard-rspec"
          \tgem "guard-rubocop"
          \tgem "guard-rubycritic"
          \tgem "rack-livereload"
        RUBY
        insert_into_file "Gemfile", guard_gems, after: /group :development do/

        # Surround with_unbundled_env to prevent errors when gems are not installed locally
        # See: https://github.com/Shopify/shopify_app/pull/89
        Bundler.with_unbundled_env { run "bundle install" }
      end

      def configure_guard
        say "Add Guardfile", :green
        template("Guardfile", "Guardfile")
      end

      def configure_rubycritic
        say "Add rubycritic configuration", :green
        template(".rubycritic.yml", ".rubycritic.yml")

        say "Add reek configuration file used by rubycritic"
        template(".reek.yml", ".reek.yml")
      end

      def configure_livereload
        say "Inject livereload into middleware", :green
        insert_into_file(
          "config/environments/development.rb",
          "\n  config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload",
          after: "Rails.application.configure do",
        )
      end

      def configure_haml_lint
        haml_lint = <<~EOL.strip
          linters:
            FinalNewline:
              enabled: false
            LineLength:
              max: 100
        EOL

        create_file ".haml-lint.yml", haml_lint
      end
    end
  end
end
