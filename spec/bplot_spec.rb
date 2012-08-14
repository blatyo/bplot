require 'spec_helper'

describe BPlot do
  let(:process){mock(:process).as_null_object}
  let(:settings){mock(:settings).as_null_object}
  let(:bplot){BPlot.new(:settings => settings, :process => process)}

  describe ".new" do
    it "should apply the settings to the gnuplot process" do
      settings.should_receive(:apply).with(process)

      bplot
    end
  end

  describe ".session" do
    it "should yield a bplot instance to the block" do
      BPlot.session(:process => process) do |plotter|
        plotter.should be_a(BPlot)
      end
    end

    it "should tell the gnu process to close" do
      process.should_receive(:close)

      BPlot.session(:process => process){}
    end
  end

  [:cmd, :set, :unset, :show].each do |method|
    describe "##{method}" do
      let(:argument){'argument'}

      it "should delegate to the gnuplot process" do
        process.should_receive(method).with(argument)

        bplot.send(method, argument)
      end
    end
  end

  [:refresh, :close].each do |method|
    describe "##{method}" do
      it "should delegate to the gnuplot process" do
        process.should_receive(method)

        bplot.send(method)
      end
    end
  end

  describe "#plot" do
    let(:x){mock(:x)}
    let(:y){mock(:y)}
    let(:style){mock(:style)}
    let(:plot){mock(:plot).as_null_object}

    it "should create a new plot with the arguments passed and draw it" do
      BPlot::Plot.should_receive(:new).with(x, y, style).and_return(plot)

      bplot.plot(x, y, style)
    end

    it "should yield a plot instance" do
      bplot.plot do |plot|
        plot.should be_a(BPlot::Plot)
      end
    end

    it "should tell the plot to draw" do
      BPlot::Plot.stub(:new).and_return(plot)
      plot.any_instance.should_receive(:draw).with(process)

      bplot.plot(x, y, style)
    end
  end
end
