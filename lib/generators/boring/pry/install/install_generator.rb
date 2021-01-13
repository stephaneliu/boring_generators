# frozen_string_literal: true

module Boring
  module Pry
    class InstallGenerator < Rails::Generators::Base
      desc "Adds pry to the application"
      source_root File.expand_path("templates", __dir__)

      def add_pry_gem
        say "Adding Pry gem", :green
        pry_gem_content = <<~RUBY
          \n
          gem "pry"
          gem "pry-rails"
        RUBY
        append_to_file "Gemfile", pry_gem_content
        run "bundle install"
      end

      def add_pryrc_configuration
        return if options[:skip_configuration]

        say "Copying pryrc configuration", :green
        template("pryrc", ".pryrc")
      end
    end
  end
end
