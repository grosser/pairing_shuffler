require "spec_helper"

describe PairingShuffler do
  let(:config){ YAML.load_file(File.expand_path("../credentials.yml", __FILE__)) }

  describe PairingShuffler::Shuffler do
    let(:shuffler){ PairingShuffler::Shuffler.new(config) }
    let(:possible){ [["a@b.com", "b@b.com"], ["a@b.com", "c@b.com"], ["b@b.com", "c@b.com"]] }

    it "has a VERSION" do
      PairingShuffler::VERSION.should =~ /^[\.\da-z]+$/
    end

    it "can read a spreadsheet" do
      shuffler.send(:content).should == [["Test list for library"], ["Email", "Team"], ["a@b.com", "A"], ["b@b.com", "B"], ["c@b.com", "C"]]
    end

    it "can return a shuffled list" do
      result = shuffler.send(:list).map(&:sort)
      result.size.should == 1
      possible.detect { |x| result.include?(x) }.should_not == nil
    end

    it "can send emails" do
      PairingShuffler::Mailer.any_instance.should_receive(:send_email).with{|emails| possible.should include(emails.sort); true }
      PairingShuffler.shuffle(config)
    end
  end
end
