require "spec_helper"

describe PairingShuffler do
  it "has a VERSION" do
    PairingShuffler::VERSION.should =~ /^[\.\da-z]+$/
  end
end
