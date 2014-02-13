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
        session = GoogleDrive.login(@config.fetch(:username), @config.fetch(:password))
        cells = session.spreadsheet_by_key(@config[:doc]).worksheets[0].cells
        data = []
        cells.each do |(row, column), value|
          data[row - 1] ||= []
          data[row - 1][column - 1] = value
        end
        data.compact
      end
    end

    def list
      emails = content.select { |row| row.first.include?("@") && present?(row) }.map(&:first)
      emails.sort_by{ rand }.each_slice(2).to_a.reject { |group| group.size == 1 }
    end

    def present?(row)
      away_until = content.map { |row| row.index("Away until") }.compact.first
      !away_until ||
        row[away_until].to_s.strip.empty? ||
        parse_time(row[away_until]) + DAY < Time.now
    end

    def parse_time(time)
      Time.strptime(time, "%m/%d/%Y")
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

        Tips:
         - Talk out loud & explain: what are you thinking / what are you going to do
         - Avoid keyboard fights: use 2 keyboards + 2 mice
         - Ping pong with tests: A writes tests, B writes implementation
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
