require 'spec_helper'

describe BPlot::DataSet do
  let(:xs){[1,2,3]}
  let(:ys){[3,2,1]}
  let(:zs){[1,2]}
  let(:data_set){BPlot::DataSet.new(xs, ys, zs)}

  describe "#each" do
    it "should iterate until the shortest dimension is exausted" do
      yielded = []
      data_set.each do |dimensions|
        yielded << dimensions
      end

      yielded.size.should == 2
    end

    it "should yield an element for each dimension" do
      data_set.each do |dimensions|
        dimensions.size.should == 3
      end
    end

    it "should yield the values" do
      yielded = []
      data_set.each do |dimensions|
        yielded << dimensions
      end

      yielded.should == [[1, 3, 1], [2, 2, 2]]
    end
  end

  describe "#to_s" do
    it "print elements separated by space, dimensions terminated by new lines, and terminated by e" do
      data_set.to_s.should == "1 3 1\n2 2 2\ne\n"
    end
  end
end