# frozen_string_literal: true

module Boring
  module CiCd
    class InstallGenerator < Rails::Generators::Base
      desc "Adds Github Action and Heroku deployment to the application"
      source_root File.expand_path("templates", __dir__)

      RUBY_VERSION_FILE = ".ruby-version"

      DEFAULT_RUBY_VERSION = ".ruby-version"
      DEFAULT_NODE_VERSION = "15.13.0"
      DEFAULT_REPOSITORY_NAME = "NOT_SPECIFIED"

      class_option :ruby_version,
                   type: :string,
                   aliases: "-v",
                   desc:
                     "Tell us the ruby version which you use for the application. Default to Ruby #{
                       DEFAULT_RUBY_VERSION
                     }, which will cause the action to use the version specified in the #{
                       RUBY_VERSION_FILE
                     } file."
      class_option :node_version,
                   type: :string,
                   aliases: "-v",
                   desc:
                     "Tell us the node version which you use for the application. Default to " \
                       "Node #{DEFAULT_NODE_VERSION}"
      class_option :repository_name,
                   type: :string,
                   aliases: "-rn",
                   desc:
                     "Tell us the repository name to be used as database name on GitHub Actions. " \
                       "Defaults to #{DEFAULT_REPOSITORY_NAME}"

      def add_github_actions_configuration
        @ruby_version = options[:ruby_version] ? options[:ruby_version] : DEFAULT_RUBY_VERSION
        @node_version = options[:node_version] ? options[:node_version] : DEFAULT_NODE_VERSION
        @repository_name =
          options[:repository_name] ? options[:repository_name] : DEFAULT_REPOSITORY_NAME

        template("ci_cd.yml", ".github/workflows/ci_cd.yml")

        say <<~WARNING, :red if @ruby_version == DEFAULT_RUBY_VERSION && !ruby_version_file_exists?
            WARNING: The action was configured to use the ruby version specified in the
            .ruby-version file, but no such file was present. Either create an appropriate
            .ruby-version file, or update .github/workflows/ci.yml to use an explicit ruby version.
          WARNING
      end

      def ruby_version_file_exists?
        Pathname.new(destination_root).join(RUBY_VERSION_FILE).exist?
      end
    end
  end
end
