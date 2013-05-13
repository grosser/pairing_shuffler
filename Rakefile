require "bundler/gem_tasks"
require "bump/tasks"
require "yaml"
require "pairing_shuffler"

task :default do
  sh "rspec spec/"
end

desc "Assign and mail paris using credentials.yml"
task :assign_pairs do
  sent = PairingShuffler.shuffle(YAML.load_file("credentials.yml"))
  puts "Sent #{sent.size} mails!"
end
