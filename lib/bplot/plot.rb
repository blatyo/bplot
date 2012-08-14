require File.expand_path('../settings', __FILE__)
require File.expand_path('../style', __FILE__)
require File.expand_path('../data_set', __FILE__)

class BPlot
  class Plot
    include Settings

    def initialize(*data_and_styles)
      raise ArgumentError, "Number of arguments should be divisible by 3." unless data_and_styles.size % 3 == 0
      @data, @styles = [], []

      extract_data_and_styles!(data_and_styles)

      yield self if block_given?
    end

    def title(title)
      set(%(title "#{title}"))
    end

    def data_set(x, y, style = {}, &block)
      add_data(x, y)
      add_style(style, &block)
    end

    def draw(process)
      apply(process)

      plot_string = to_s

      draw_plot(process, plot_string) unless plot_string.empty?
    end

    def to_s
      style_stream = @styles.map(&:to_s).join(', ')
      data_stream = @data.map(&:to_s).join

      "#{style_stream} \n#{data_stream}".strip
    end

  protected

    def draw_plot(process, plot_string)
      process.plot(plot_string)
    end

    def add_data(*dimensions)
      @data << DataSet.new(*dimensions)
    end

    def add_style(style)
      style = Style.new(style)
      yield style if block_given?
      @styles << style
    end

    def extract_data_and_styles!(data_and_styles)
      # Arity is negative when there is a default argument
      arity = method(:data_set).arity.abs

      data_set(*data_and_styles.shift(arity)) until data_and_styles.empty?
    end
  end
end
