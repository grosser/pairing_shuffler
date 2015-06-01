require "bundler/setup"
require "bundler/gem_tasks"
require "bump/tasks"
require "yaml"
require "pairing_shuffler"

task :default do
  sh "rspec spec/"
end

desc "Produce an access token"
task :token do
  require "google/api_client"
  require "google_drive"
  config = YAML.load_file("credentials.yml")
  client = Google::APIClient.new
  auth = client.authorization
  auth.client_id = config.fetch(:client_id)
  auth.client_secret = config.fetch(:client_secret)
  auth.scope = [
    "https://www.googleapis.com/auth/drive",
    "https://spreadsheets.google.com/feeds/"
  ]
  auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
  print("2. Enter the authorization code shown in the page: ")
  auth.code = $stdin.gets.chomp
  auth.fetch_access_token!
  puts "Add this token to credentials.yml: #{auth.access_token}"
end

desc "Assign and mail paris using credentials.yml"
task :assign_pairs do
  sent = PairingShuffler.shuffle(YAML.load_file("credentials.yml"))
  puts "Sent #{sent.size} mails!"
  puts sent.map { |tos| tos.join(" + ") }.join("\n")
end

namespace :test do
  task :mail do
    to = ENV["TO"] || raise("set TO=mail@domain.com,other@foo.com")
    PairingShuffler::Mailer.new(YAML.load_file("credentials.yml")).session do |mailer|
      mailer.notify(to.split(","))
    end
  end
end
