require "bundler/setup"
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

namespace :test do
  task :mail do
    to = ENV["TO"] || raise("set TO=mail@domain.com,other@foo.com")
    PairingShuffler::Mailer.new(YAML.load_file("credentials.yml")).session do |mailer|
      mailer.notify(to.split(","))
    end
  end
end
