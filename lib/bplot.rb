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


# BPlot is a 2D and 3D plotting module for SciRuby. It provides a
# simple API that will be familiar to Gnuplot users and to a lesser
# extent Matlab users. BPlot is in ALPHA status. Two dimmensional
# plots seem to work well but they really need more testing. Also,
# the API is not yet settled and may change without warning. Many
# features are not yet implemented, including surface plots.
class BPlot
	# === Create new engine
	# 
	# Every call to BPlot#new creates a new instance of Gnuplot. You can
	# have multiple instances of Gnuplot in the same Ruby script.
	#
	# === Example
	#
	#   b.BPlot.new
	#   b.cmd('plot sin(x)')
	# 
	def initialize()
		#
		# Every instance of BPlot has its own gnuplot process.
		#
		@pipe = IO.popen("gnuplot -p","w")
		
		#
		# Configure Gnuplot.
		#
		@pipe.puts "set terminal wxt"			# Nice GUI for plots.
		@pipe.puts "set termoption dashed"		# Needed for 'r--', 'r.-', 'r:'
		@pipe.puts "set termoption enhanced"	# Support superscripts + subscripts.
	end
	
	#
	# === Issue raw command
	# 
	# Send a raw command to the Gnuplot backend.
	# This gives the user more control over plotting engine.
	#
	# === Example
	#
	#   b.BPlot.new
	#   b.cmd('plot sin(x)')
	#
	def cmd(str)
		@pipe.puts str
	end
	
	#
	# === Settings
	# 
	# This method is a thin wrapper around the Gnuplot "set" command.
	# It can be used to set *a lot* of options. However, nothing is
	# drawn until the user issues a plotting command. See the examples
	# below for a quick overview. See the Gnuplot documentation for
	# more details.
	#
	# === Examples
	#
	#   b.set('terminal enhanced postscript color')
	#   b.set('output "myplot.ps"')
	#   b.set('xrange [0:10]')
	#   b.set('yrange [0:50]')
	#   b.set('xlabel "This is the X Axis"')
	#   b.set('ylabel "This is the Y Axis"')
	#   b.set('title "A title for the whole plot"')
	#
	def set(str)
		@pipe.puts "set #{str}"
	end
	
	# === Settings
	# 
	# This method is a thin wrapper around the Gnuplot "unset" command.
	# It is used to reset settings back to their default values. See
	# the documentation on "set" for more information. See also the
	# Gnuplot documentaion for "set" and "unset".
	def unset(str)
		@pipe.puts "unset #{str}"
	end
	
	# === Show
	#
	# The `set` command can be used to set *lots* of options.  No screen is
	# drawn, however, until a plotting command is given. The *show* command
	# shows their settings; show('all') shows all the settings.
	#
	def show(str)
		@pipe.puts "show #{str}"
	end
	
	#
	# === Refresh
	#
	# This command reformats and redraws the current plot with the latest
	# settings. This is useful for viewing a plot with different "set"
	# options, or for generating the same plot for several output formats.
	#
	# === Example
	#
	#   b.set('terminal postscript')
	#   b.set('output "myplot.ps"')
	#   b.refresh
	#   
	#   b.set('terminal png')
	#   b.set('output "myplot.png"')
	#   b.refresh
	#
	def refresh()
		@pipe.puts "refresh"
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
	#   b.multiplot do
	#     plot(x, y1)
	#     plot(x, y2)
	#     plot(x, y3)
	#   end
	#   
	#   b.multiplot do
	#     (0..10).each { |t| plot( x, sin(x + v*t) ) }
	#   end
	def multiplot(opts='')
		@pipe.puts "set multiplot #{opts}"
		yield if block_given?
		@pipe.puts "unset multiplot"
	end
	
	# == 2D Plotting
	# 
	# This is the key method in BPlot, as it is responsible for all 2D plots. This
	# method is currently in a state of flux and is for the moment undocumented.
	def plot(*args)
		
		all_data = []
		all_plots = ''
		while args.length > 0
			#
			# NEXT PLOT
			#
			# Anything that is of class Array or NMatrix is data.
			this_data = []
			while args[0].class == 'Array' or args[0].class == 'NMatrix'
				this_data << args.shift
			end
			
			all_data << this_data
			
			# - Get the settings for this plot.
			# - If 'args' is not empty, there is another plot.
			this_plot, args = styles(args)
			all_plots << this_plot
			all_plots << ', ' if args.length > 0
		end
		
		# TODO:
		#   -   Check for both Array and NMatrix.
		#   -   But make sure the program works without NMatrix loaded.
		#
		
		#
		# Each plot needs a separate stream of data separated by 'e' ("end").
		#
		nblocks = all_data.length
		
		stream = (1..nblocks).map { |s|
			
			ncols = all_data[s].length
			nrows = all_data[s][0].class == 'Array' ? all_data[s][0].length
			                                        : all_data[s][0].shape[0] - 1
			
			(0..nrows).map { |r|
			(0..ncols).map { |c|  "     " + all_data[s][c][r]
			}.join + "\n"
			}.join + "e\n"
		}.join
		
#		stream = (1..nstreams).map { |s|
#			x = data.shift
#			y = data.shift
#			n = x.is_a?(Array) ? x.length - 1 : x.shape[0] - 1
#			
#			(0..n).map { |i| "#{x[i]}	#{y[i]}\n" }.join + "e\n"
#		}.join
		
		@pipe.puts "plot #{all_plots} \n#{stream}"
	end
	
	###############################
	#
	#  PRIVATE METHODS
	#
	###############################
	
	private
	
	#
	# - Get all the stye information for the next plot from 'args'.
	# - Return the styles as a string, and the remainder of 'args'.
	#
	def styles(args)
		
		with  = ''
		title = ''
		color = ''
		style = " '-' "
		
		if args[0].is_a?(String)
			
			opts = args.shift
			opts = opts.split(/;/)
			
			#
			# Gnuplot 'with' beats Matlab's.
			#
			with = gnu_with(opts[2]) if opts[2]
			with = mat_with(opts[0]) if with == ''
			
			style << mat_style(opts[0])
			style << gnu_style(opts[2]) if opts[2]
			
			title = opts[1] if opts.length >= 1
		end
		
		if args[0].is_a?(Hash)
			#
			# Incidentally, if we are here, this is the end of the plot command.
			#
			opts = args.shift
			
			title  = opts[:title]  if opts[:title]
			color  = opts[:color]  if opts[:color]
			
			#
			# Infer the 'with' command for :lines and :points.
			#
			if opts[:lines]
				lw, lt = opts[:lines].split(/;/)
				
				lw = lw.to_i
				lw = 1  if lw == 0
				
				lt = 1  if lt == '' or lt == nil
				lt = 1  if lt.to_s =~ /solid/i
				lt = 2  if lt.to_s =~ /dashed/i
				lt = 3  if lt.to_s =~ /dot/i
				lt = 4  if lt.to_s =~ /dot-dashed/i
				lt = 5  if lt.to_s =~ /dot-dot-dashed/i
				
				style << " lw #{lw} " if lw.is_a?(Fixnum)
				style << " lt #{lt} " if lt.is_a?(Fixnum)
			end
			if opts[:points]
				ps, pt = opts[:points].split(/;/)
				
				ps = ps.to_i
				ps = 1  if ps == 0
				
				pt = 1  if pt == ''
				pt = 1  if pt == '+'
				pt = 2  if pt == 'x' or pt == 'X'
				pt = 3  if pt == '*'
				pt = 1  if pt.to_s =~ /plus/i
				pt = 2  if pt.to_s =~ /cross/i
				pt = 3  if pt.to_s =~ /star/i
				
				pt = 4  if pt.to_s =~ /open-square/i
				pt = 6  if pt.to_s =~ /open-circle/i
				pt = 12 if pt.to_s =~ /open-diamond/i
				pt = 8  if pt.to_s =~ /open-up-triangle/i
				pt = 10 if pt.to_s =~ /open-down-triangle/i
				
				pt = 5  if pt.to_s =~ /solid-square/i
				pt = 7  if pt.to_s =~ /solid-circle/i
				pt = 13 if pt.to_s =~ /solid-diamond/i
				pt = 9  if pt.to_s =~ /solid-up-triangle/i
				pt = 11 if pt.to_s =~ /solid-down-triangle/i
				
				style << " ps #{ps} " if ps.is_a?(Fixnum)
				style << " pt #{pt} " if pt.is_a?(Fixnum)
			end
			
			#
			# "with" strings from both Matlab and Gnuplot take precedence.
			#
			# In other words:  Gnuplot > Matlab > Named parameters. 
			#
			if with == ''
				with = 'with lines'       if opts[:lines]
				with = 'with points'      if opts[:points]
				with = 'with linespoints' if opts[:lines] and opts[:points]
			end
		end
		
		
		#
		# Finish up the command (title, colour, 'with', etc).
		#
		style << " lc rgb \"#{color}\" " if color != ''
		style << " title  \"#{title}\" "
		style << with if with
		
		return style, args
	end
	
	
	def gnu_with(s)
		regex = /\b([wW][iI]?[tT]?[hH]? +\w+)/
		s =~ regex ? s.scan(regex).last.first : ''
	end
	def gnu_style(str)
		str.gsub(/\b([wW][iI]?[tT]?[hH]? +\w+)/, '')
	end
	
	def mat_with(s)
		wp = s =~ /[xsovdph<>+*^]/ ? true : false
		wl = s =~ /[-:.]/ ? true : false
		
		return " with linespoints " if wp and wl
		return " with points "		if wp
		return " with lines "       if wl
	end
	def mat_style(mat)
		style = '';
		
		# Colour:
		style << " lc 1 " if mat =~ /r/
		style << " lc 2 " if mat =~ /g/
		style << " lc 3 " if mat =~ /b/
		style << " lc 4 " if mat =~ /m/
		style << " lc 5 " if mat =~ /c/
		style << " lc 6 " if mat =~ /y/
		style << " lc 7 " if mat =~ /k/
		
		# Line styles:
		style << " pt 1  " if mat =~ /\+/
		style << " pt 2  " if mat =~ /x/
		style << " pt 3  " if mat =~ /\*/
		style << " pt 5  " if mat =~ /s/
		style << " pt 6  " if mat =~ /o/
		style << " pt 9  " if mat =~ /\^/
		style << " pt 11 " if mat =~ /v/
		style << " pt 13 " if mat =~ /d/
		
		# Styles I cannot duplicate properly:
		style << " pt 8  " if mat =~ /</  # open up triangle.
		style << " pt 10 " if mat =~ />/  # open down triangle.
		style << " pt 12 " if mat =~ /p/  # open diamond
		style << " pt 7  " if mat =~ /h/  # solid circle
		
		#
		# Extra remaining style (non-Matlab).
		#
		style << " pt 4  " if mat =~ /q/  # open square
		
		# Line styles
		style << " lt 1 " if mat =~ /-/ and mat !~ /--/ and mat !~ /\.-/ and mat !~ /\.\.-/
		style << " lt 4 " if mat =~ /\.-/ and mat !~ /\.\.-/
		style << " lt 5 " if mat =~ /\.\.-/
		style << " lt 2 " if mat =~ /--/
		style << " lt 3 " if mat =~ /:/
		
		return style
	end
end


