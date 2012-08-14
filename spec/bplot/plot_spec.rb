require 'spec_helper'

describe BPlot::Plot do
  let(:empty_plot) do
    BPlot::Plot.new
  end

  let(:simple_plot) do
    BPlot::Plot.new([1], [2], :lines => "1;+")
  end

  let(:complex_plot) do
    BPlot::Plot.new(
      [1], [2], "ro--;y = x^4;ps 3 lw 3", 
      [2], [3], "bo--;y = x^4;ps 3 lw 3"
    )
  end

  let(:three_arg_plot_string){"'-'  lw 1  title  \"\"  \n1 2\ne"}
  let(:many_arg_plot_string){"'-'  lc 1  pt 6   lt 2 ps 3 lw 3 title  \"y = x^4\"  with linespoints ,  '-'  lc 3  pt 6   lt 2 ps 3 lw 3 title  \"y = x^4\"  with linespoints  \n1 2\ne\n2 3\ne"}
  let(:process){mock(:process)}

  describe ".new" do
    it "should raise an exception when arguments are not divisible by 3" do
      expect{BPlot::Plot.new([], [])}.to raise_error(ArgumentError)      
    end
  end

  describe "#draw" do
    it "should do nothing if the nothing was specified for the plot" do
      process.should_not_receive(:set)
      process.should_not_receive(:unset)
      process.should_not_receive(:plot)

      empty_plot.draw(process)
    end

    it "should plot when three arguments are given" do
      process.should_receive(:plot).with(three_arg_plot_string)

      simple_plot.draw(process)
    end

    it "should plot when many arguments are given" do
      process.should_receive(:plot).with(many_arg_plot_string)

      complex_plot.draw(process)
    end
  end

  describe "#to_s" do
    it "should produce empty string when nothing is provided" do
      empty_plot.to_s.should == ""
    end

    it "should produce a plot string when 3 arguments are provided" do
      simple_plot.to_s.should == three_arg_plot_string
    end

    it "should produce a plot string when many arguments are provided" do
      complex_plot.to_s.should == many_arg_plot_string
    end
  end

  describe "#data_set" do
    it "should add a new dataset to be plotted" do
      empty_plot.data_set([1], [2], :lines => "1;+")

      empty_plot.to_s.should == three_arg_plot_string
    end

    it "should add a new dataset and yield a style" do
      empty_plot.data_set([1], [2]) do |style| 
        style.lines "1;+"
        style.should be_a(BPlot::Style)
      end

      empty_plot.to_s.should == three_arg_plot_string
    end
  end
end