# frozen_string_literal: true

require "test_helper"
require "generators/boring/audit/install/install_generator"

class AuditInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Audit::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_install_audit_gem_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file "Gemfile" do |content|
        assert_match(/bundler-audit/, content)
        assert_match(/ruby_audit/, content)
      end
    end
  end
end
