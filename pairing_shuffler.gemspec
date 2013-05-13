$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
name = "pairing_shuffler"
require "#{name.gsub("-","/")}/version"

Gem::Specification.new name, PairingShuffler::VERSION do |s|
  s.summary = "Assign random pairs from a google docs spreadsheet"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.license = "MIT"
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem")
  s.cert_chain = ["gem-public_cert.pem"]
  s.add_runtime_dependency "google_drive"
end
