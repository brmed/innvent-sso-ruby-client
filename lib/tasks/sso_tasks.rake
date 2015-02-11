require 'fileutils'
namespace :sso_client do
  desc "Installs required stuff for sso client..."
  task :install do
    Rails.logger = Logger.new(STDOUT)
    source = File.join(Gem.loaded_specs["sso_client"].full_gem_path, "misc", "sso_client.yml")
    target = File.join(Rails.root, "config", "sso_client.yml")
    Rails.logger.info "Creating file #{target}"
    FileUtils.cp_r(source, target)

    source = File.join(Gem.loaded_specs["sso_client"].full_gem_path, "misc", "server_key.pub")
    target = File.join(Rails.root, "config", "server_key.pub")
    Rails.logger.info "Creating file #{target}"
    FileUtils.cp_r(source, target)
  end
end
