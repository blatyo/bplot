require 'spec_helper'

describe BPlot::Style do
  let(:style_string) do
    'go--;y = x^4;ps 3 lw 3'
  end

  let(:style_hash) do
    {
      :title => 'x^3',
      :color => 'blue',
      :lines => '2;dashed',
      :points => '2;*'
    }
  end

  let(:style_proc) do
    Proc.new do |style|
      style.title 'x^2' 
      style.color 'red'
      style.lines '1;solid'
    end
  end

  let(:style_from_string) do
    BPlot::Style.new(style_string)
  end

  let(:style_from_hash) do
    BPlot::Style.new(style_hash)
  end

  let(:style_from_block) do
    BPlot::Style.new(&style_proc)
  end

  let(:style_from_string_and_block) do
    BPlot::Style.new(style_string, &style_proc)
  end

  let(:style_from_hash_and_block) do
    BPlot::Style.new(style_hash, &style_proc)
  end

  describe "#to_s" do
    it "should generate the correct string when given a string" do
      style_from_string.to_s.should == " '-'  lc 2  pt 6   lt 2 ps 3 lw 3 title  \"y = x^4\"  with linespoints "
    end

    it "should generate the correct string when given a hash" do
      style_from_hash.to_s.should == " '-'  lw 2  lt 2  ps 2  pt 3  lc rgb \"blue\"  title  \"x^3\" "
    end

    it "should generate the correct string when initialized from a block" do
      style_from_block.to_s.should == " '-'  lw 1  lt 1  lc rgb \"red\"  title  \"x^2\" "
    end

    it "should replace all style settings from a string when any settings from the block is specified" do
      style_from_string_and_block.to_s.should == " '-'  lw 1  lt 1  lc rgb \"red\"  title  \"x^2\" "
    end

    it "should replace style settings from the hash with style settings from the block" do
      style_from_hash_and_block.to_s.should == " '-'  lw 1  lt 1  ps 2  pt 3  lc rgb \"red\"  title  \"x^2\" "
    end
  end
end