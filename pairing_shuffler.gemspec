name = "pairing_shuffler"
require "./lib/#{name}/version"

Gem::Specification.new name, PairingShuffler::VERSION do |s|
  s.summary = "Assign random pairs from a google docs spreadsheet"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files lib bin`.split("\n")
  s.license = "MIT"
  s.add_runtime_dependency "google_drive", ">= 1.0.0"
end
