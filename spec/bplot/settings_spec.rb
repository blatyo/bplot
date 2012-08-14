require 'spec_helper'

describe BPlot::Settings do
  let(:settings_class) do
    Class.new do
      include BPlot::Settings

      set "something"
      set "something else"
      unset "everything else"

      def set_some_stuff
        set "some"
        set "stuff"
      end

      def unset_some_stuff
        unset "some"
        unset "stuff"
      end
    end
  end

  let(:settings) do
    settings_class.new.tap do |setter|
      setter.set_some_stuff
      setter.unset_some_stuff
    end
  end

  let(:process){mock(:process)}

  let(:expected_properties) do
    [
      [:set, "something"],
      [:set, "something else"],
      [:unset, "everything else"],
      [:set, "some"],
      [:set, "stuff"],
      [:unset, "some"],
      [:unset, "stuff"]
    ]
  end

  describe "#apply" do
    it "should apply class level and instance level settings to the process" do
      i = 0
      process.should_receive(:set) do |property|
        method, expected_property = expected_properties[i]
        method.should == :set
        property.should == expected_property
        i += 1
      end.exactly(4).times

      process.should_receive(:unset) do |property|
        method, expected_property = expected_properties[i]
        method.should == :unset
        property.should == expected_property
        i += 1
      end.exactly(3).times

      settings.apply(process)
    end
  end
end