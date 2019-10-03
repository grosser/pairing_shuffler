require "spec_helper"

describe PairingShuffler do
  let(:config){ YAML.load_file(File.expand_path("../credentials.yml", __FILE__)) }

  describe PairingShuffler::Shuffler do
    let(:shuffler){ PairingShuffler::Shuffler.new(config) }
    let(:possible){ [["a@b.com", "b@b.com"], ["a@b.com", "c@b.com"], ["b@b.com", "c@b.com"]] }

    it "has a VERSION" do
      PairingShuffler::VERSION.should =~ /^[\.\da-z]+$/
    end

    # paste correct values into a test-sheet to have this work ...
    context "integration" do
      it "can read a spreadsheet" do
        shuffler.send(:content).should == [
          ["Test list for library"],
          ["Email", "Team", "Interested in", "Working on", "Away until"],
          ["a@b.com", "Team-A", "", "", "2/5/2016"],
          ["b@b.com", "Team-B"],
          ["c@b.com", "Team-C", "", "Nothing", "10/23/2015"]
        ]
      end

      it "can return a shuffled list" do
        result = shuffler.send(:list).map(&:sort)
        result.size.should == 1
        possible.detect { |x| result.include?(x) }.should_not == nil
      end

      it "can send emails" do
        # TODO: use satisfy matcher here somehow to silence deprecation
        PairingShuffler::Mailer.any_instance.should_receive(:send_email).with{|emails| possible.should include(emails.sort); true }
        PairingShuffler.shuffle(config)
      end
    end

    it "does not read non-emails" do
      shuffler.stub(:content).and_return [["Test list for library"], ["Email", "Team"], ["a@b.com", "A"], ["b@b.com", "B"], ["nope", "C"], ["c@b.com", "C"]]
      result = shuffler.send(:list).map(&:sort)
      result.size.should == 1
      possible.should include result.first
    end

    context "Away until" do
      let(:day) { 24 * 60 * 60 }

      it "does not include people that are away" do
        shuffler.stub(:content).and_return [
          ["Test list for library"],
          ["Email", "Team", "Away until"],
          ["a@b.com", "A"],
          ["b@b.com", "B", Time.now.strftime("%m/%d/%Y")],
        ]
        shuffler.send(:list).size.should == 0
      end

      it "include people that are back with weird content" do
        shuffler.stub(:content).and_return [
          ["Test list for library"],
          ["Email", "Team", "Away until"],
          ["a@b.com", "A"],
          ["b@b.com", "B", "On PTO until #{(Time.now - day).strftime("%m/%d/%Y")}"],
        ]
        shuffler.send(:list).size.should == 1
      end

      it "includes people that are back" do
        shuffler.stub(:content).and_return [
          ["Test list for library"],
          ["Email", "Team", "Away until"],
          ["a@b.com", "A"],
          ["b@b.com", "B", (Time.now - day).strftime("%m/%d/%Y")],
        ]
        shuffler.send(:list).size.should == 1
      end

      it "includes unreadable dates since otherwise nobody will ever fix them" do
        shuffler.stub(:content).and_return [
          ["Test list for library"],
          ["Email", "Team", "Away until"],
          ["a@b.com", "A"],
          ["b@b.com", "B", "I'll be back!"],
        ]
        shuffler.send(:list).size.should == 1
      end
    end
  end
end
