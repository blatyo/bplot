require 'spec_helper'

describe BPlot::Process do
  let(:pipe){mock(:pipe)}
  let(:process){BPlot::Process.new}

  before(:each) do
    IO.stub(:popen).and_return(pipe)
  end

  describe "#cmd" do
    it "should pass the string to the pipe" do
      pipe.should_receive(:puts).with('a')

      process.cmd 'a'
    end
  end

  describe "#set" do
    it "should pass 'set <string>' to the pipe" do
      pipe.should_receive(:puts).with('set a')

      process.set 'a'
    end
  end

  describe "#unset" do
    it "should pass 'unset <string>' to the pipe" do
      pipe.should_receive(:puts).with('unset a')

      process.unset 'a'
    end
  end

  describe "#show" do
    it "should pass 'show <string>' to the pipe" do
      pipe.should_receive(:puts).with('show a')

      process.show 'a'
    end
  end

  describe "#plot" do
    it "should pass 'plot <string>' to the pipe" do
      pipe.should_receive(:puts).with('plot a')

      process.plot 'a'
    end
  end

  describe "#splot" do
    it "should pass 'splot <string>' to the pipe" do
      pipe.should_receive(:puts).with('splot a')

      process.splot 'a'
    end
  end

  describe "#refresh" do
    it "should pass 'refresh' to the pipe" do
      pipe.should_receive(:puts).with('refresh')

      process.refresh
    end
  end

  describe "#close" do
    it "should pass 'exit' to the pipe" do
      pipe.should_receive(:puts).with('exit')

      process.close
    end
  end
end