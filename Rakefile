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
  require "googleauth"
  config = YAML.load_file("credentials.yml")
  credentials = Google::Auth::UserRefreshCredentials.new(
    client_id: config.fetch(:client_id),
    client_secret: config.fetch(:client_secret),
    scope: [
      "https://www.googleapis.com/auth/drive",
      "https://spreadsheets.google.com/feeds/",
    ],
    # additional_parameters: { "access_type" => "offline" },
    redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
  )
  print("1. Open this page:\n#{credentials.authorization_uri}\n\n")
  print("2. Enter the authorization code shown in the page: ")
  credentials.code = $stdin.gets.chomp
  credentials.fetch_access_token!
  puts "Add this token to credentials.yml: #{credentials.refresh_token}"
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
