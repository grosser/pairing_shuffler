require "pairing_shuffler/version"
require "google_drive"
require "net/smtp"

module PairingShuffler
  def self.shuffle(config)
    Shuffler.new(config).send_emails
  end

  class Shuffler
    DAY = 24 * 60 * 60

    def initialize(config)
      @config = config
    end

    def send_emails
      Mailer.new(@config).session do |mailer|
        list.each do |emails|
          mailer.notify(emails)
        end
      end
    end

    private

    def content
      @content ||= begin
        session = GoogleDrive.login_with_oauth(access_token)
        cells = session.spreadsheet_by_key(@config[:doc]).worksheets[0].cells
        data = []
        cells.each do |(row, column), value|
          row -= 1 # change to 0-based index
          column -= 1 # change to 0-based index
          (data[row] ||= [])[column] = value
        end
        data.compact
      end
    end

    def access_token
      params = {
        :client_id => @config.fetch(:client_id),
        :client_secret => @config.fetch(:client_secret),
        :refresh_token => @config.fetch(:refresh_token),
        :grant_type => "refresh_token"
      }.map { |k, v| "-d '#{k}=#{v}'" }.join(" ")
      response = `curl https://accounts.google.com/o/oauth2/token --silent -X POST #{params}`

      # cannot use curls --fail since it would hide error details
      $?.success? && response.start_with?("{") && token = JSON.load(response)["access_token"]
      raise "FAILED: #{response}" unless token

      token
    end

    def list
      emails = content.compact.select { |row| row.first.to_s.include?("@") && present?(row) }.map(&:first)
      emails.sort_by{ rand }.each_slice(2).to_a.reject { |group| group.size == 1 }
    end

    def present?(row)
      return true unless away_until = content.map { |row| row.index("Away until") }.compact.first
      return true unless time = parse_time(row[away_until])
      time + DAY < Time.now
    end

    def parse_time(time)
      return unless date = time.to_s[/\d+\/\d+\/\d+/]
      Time.strptime(date, "%m/%d/%Y")
    end
  end

  class Mailer
    attr_reader :config

    def initialize(config)
      @config = config
    end

    # Google returns 535-5.7.1 on to frequent auth -> only do it once
    def session
      @session = true
      yield self
    ensure
      @session = false
      stop_smtp
    end

    def notify(emails)
      subject = "PairingShuffler winners"
      url = config[:short] || "https://docs.google.com/spreadsheet/ccc?key=#{config[:doc]}"
      # FYI: if the first line is a url the email is blank in gmail
      body = <<-MAIL.gsub(/^ {8}/, "")
        Hello #{emails.map{|e|e.sub(/@.*/,"")}.join(" & ")}!

        You both singed up for PairingShuffler at #{url}
        so let's pair!

        What time would work for you ?

        Tips:
         - Talk out loud & explain: what are you thinking / what are you going to do
         - Ping pong with tests: A writes tests, B writes implementation
         - check out https://robots.thoughtbot.com/how-to-get-better-at-pair-programming
         - Invite others to sign up for pairing

        Greetings,
        PairingShuffler
      MAIL
      send_email(emails, :subject => subject, :body => body)
    end

    private

    def send_email(tos, options={})
      tos.each do |to|
        message = <<-MESSAGE.gsub(/^ {10}/, "")
          From: PairingShuffler <#{config.fetch(:username)}>
          To: #{to}
          Reply-To: #{(tos - [to]).join(", ")}
          Subject: #{options.fetch(:subject)}

          #{options.fetch(:body)}
        MESSAGE
        smtp.send_message message, config.fetch(:username), to
      end
    end

    def smtp
      raise unless @session
      @smtp ||= begin
        smtp = Net::SMTP.new "smtp.gmail.com", 587
        smtp.enable_starttls
        smtp.start("gmail.com", config.fetch(:username), config.fetch(:password), :login)
        smtp
      end
    end

    def stop_smtp
      @smtp.finish if @smtp && @smtp.started?
    end
  end
end
