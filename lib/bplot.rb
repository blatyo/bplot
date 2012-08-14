=begin
TODO: SURFACE PLOTS
-------------------

x = N[1,2,3,4,5]
y = x

x,y = meshgrid(x,y)

z = x*x + y*y

b.splot(x,y,z)

=end

#
# I'll document this function when I implement surface plots.
#
=begin
def meshgrid(x,y)
	warn "Input to meshgrid() must be 1 dimensional" if x.dim > 1
	warn "Input to meshgrid() must be 1 dimensional" if y.dim > 1

	xn = x.shape[0]
	yn = y.shape[0]

	xx = NMatrix.new( [xn,xn], (0..xn-1).map { |i| x[i] } )
	yy = NMatrix.new( [yn,yn], (0..yn-1).map { |i| y[i] } )

	return xx, yy.transpose
end
=end
require 'forwardable'
require File.expand_path('../bplot/process', __FILE__)
require File.expand_path('../bplot/plot', __FILE__)

# BPlot is a 2D and 3D plotting module for SciRuby. It provides a
# simple API that will be familiar to Gnuplot users and to a lesser
# extent Matlab users. BPlot is in ALPHA status. Two dimmensional
# plots seem to work well but they really need more testing. Also,
# the API is not yet settled and may change without warning. Many
# features are not yet implemented, including surface plots.
class BPlot
	extend Forwardable

	class << self
		def session(options = {})
			bplot = new(options)
			yield bplot if block_given?
			bplot.close
		end
	end

	delegate [:cmd, :set, :unset, :show, :refresh, :close] => :@process

	# === Create new engine
	#
  # By default BPlot#new will create an instance of BPlot::Process, which
  # means a new instance of Gnuplot. You can have multiple instances of
  # Gnuplot in the same Ruby script.
  #
  # You can also instantiate an instance of BPlot::Process or an object
  # that implements it's interface and pass it as the first argument.
	#
	# === Example
	#
	#   b = BPlot.new
	#   b.plot(x, y)
	#
	def initialize(options = {})
		@process = options[:process] || BPlot::Process.new
    settings = options[:settings] || DefaultSettings.new
    apply(settings)
	end

	def apply(settings)
		settings.apply(@process)
	end

	# == Multiplot
	#
	# In multiplot mode, multiple plot commands are placed togeher in the
	# same window. This can be a convenient alternative to having a very
	# long multiple-line plot command. It allso allows you to add plots
	# using loops and other constructions.
	#
	# == Examples
	#
	#   b.multiplot do |mp|
	#     mp.plot(x, y1)
	#     mp.plot(x, y2)
	#     mp.plot(x, y3)
	#   end
	#
	#   b.multiplot do |mp|
	#     (0..10).each { |t| mp.plot( x, sin(x + v*t) ) }
	#   end
	def multiplot(opts='')
		@process.set "multiplot #{opts}"
		yield self if block_given?
		@process.unset "multiplot"
	end

	# == 2D Plotting
	#
	# This is the key method in BPlot, as it is responsible for all 2D plots. This
	# method is currently in a state of flux and is for the moment undocumented.
	def plot(*args)
		plot = Plot.new(*args)
		yield plot if block_given?
		plot.draw(@process)
	end
end
