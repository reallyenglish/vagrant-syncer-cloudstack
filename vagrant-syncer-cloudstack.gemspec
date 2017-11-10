
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vagrant/syncer/cloudstack/version"

Gem::Specification.new do |spec|
  spec.name          = "vagrant-syncer-cloudstack"
  spec.version       = Vagrant::Syncer::Cloudstack::VERSION
  spec.authors       = ["Tomoyuki Sakurai"]
  spec.email         = ["tomoyukis@reallyenglish.com"]

  spec.summary       = "sync virtual machine states on remote cloudstack"
  spec.description   = "sync virtual machine states on remote cloudstack"
  spec.homepage      = "https://github.com/reallyenglish/#{spec.name}"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "cloudstack_client", "~> 1.5.3"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.47.1"
end
