require "pairing_shuffler/version"
require "google_drive"
require "net/smtp"

module PairingShuffler
  def self.shuffle(config)
    Shuffler.new(config).send_emails
  end

  class Shuffler
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
        data
      end
    end

    def list
      emails = content[2..-1].map(&:first)
      emails.sort_by{ rand }.each_slice(2).to_a.reject { |group| group.size == 1 }
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
      # FYI: if the first line is a url the email is blank in gmail
      body = "Hello there!\nYou both singed up for PairingShuffler at https://docs.google.com/spreadsheet/ccc?key=#{config[:doc]}\nso let's pair!\n\nGreetings PairingShuffler"
      send_email(emails, :subject => subject, :body => body)
    end

    private

    def send_email(to, options={})
      message = <<-MESSAGE.gsub(/^\s+/, "")
      From: PairingShuffler <#{config.fetch(:username)}>
      To: #{to.join(", ")}
      Subject: #{options.fetch(:subject)}

      #{options.fetch(:body)}
      MESSAGE

      smtp.send_message message, config.fetch(:username), to
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
