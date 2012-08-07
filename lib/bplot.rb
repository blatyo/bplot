=begin
BPlot -- A ploting module for SciRuby. It provides an API
         familiar to Gnuplot users and to a lesser extent
         Matlab users.

                 \     /
             \    o ^ o    /
               \ (     ) /
    ____________(%%%%%%%)____________
   (     /   /  )%%%%%%%(  \   \     )
   (___/___/__/           \__\___\___)
      (     /  /(%%%%%%%)\  \     )
       (__/___/ (%%%%%%%) \___\__)      A hard-working bee.
               /(       )\
             /   (%%%%%)   \
                  (%%%)
                    !

EXAMPLES: 2D PLOTS
-------------------

require 'bplot'

x = [1,2,3,4,5]
y = [1,4,9,16,25]
z = [25,20,15,10,5]

b = BPlot.new

#
# Send a raw command into Gnuplot.
#
b.cmd('plot sin(x) title "Plot without Ruby."')


#
# Gnuplot 'set' command.
#
b.set('xrange [0:6]')
b.set('yrange [0:30]')
b.set('title "Heading for the entire plot"')


#
# Gnuplot 'replot' command.
#
b.replot


#
# Basic plots.
#
b.plot(x, y)
b.plot(x, y, 'ps 2', 'rh')
b.plot(x, y, 'ps 2', 'rh--', 'y = x^2')

#
# The 'with' command on the gnuplot string takes precedence.
#
b.plot(x, y, 'ps 2 w lp', 'rh')
b.plot(x, y, 'ps 2 with steps', 'rh')


#
# Named parameters.
#
b.plot(x, y, :title => 'Density', :gnuplot => 'lc 3 ps 1.5 lt 4 pt 5 w lp')
b.plot(x, y, :title => 'Density', :gnuplot => 'ps 1.5', :matlab => 'rh-')
b.plot(x, y, :t => 'Mass', :g => 'ps 2.5', :m => 'bh--')


#
# Multiple data sets (need not be the same length).
#
b.plot(x, y, 'ps 2', 'rh-', x, z, 'ps 1.5', 'bs--')
b.plot(x, y, 'ps 2', 'rh-', 'Quadratic', x, z, 'ps 1.5', 'bs--', 'Linear')


# Observe that named parameters must be at the end. Hence, they only apply to the last plot.

b.plot(x, y, 'ps 2', 'rh-',       'Quadratic', x, z, 'ps 1.5', 'bs--', :t => 'Linear') # OK.
b.plot(x, y, 'ps 2', 'rh-', :t => 'Quadratic', x, z, 'ps 1.5', 'bs--',       'Linear') # ERROR.



========================================
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
def meshgrid(x,y)
	warn "Input to meshgrid() must be 1 dimensional" if x.dim > 1
	warn "Input to meshgrid() must be 1 dimensional" if y.dim > 1
	
	xn = x.shape[0]
	yn = y.shape[0]
	
	xx = NMatrix.new( [xn,xn], (0..xn-1).map { |i| x[i] } )
	yy = NMatrix.new( [yn,yn], (0..yn-1).map { |i| y[i] } )
	
	return xx, yy.transpose
end

class BPlot
	def initialize()
		#
		# Every instance of BPlot has its own gnuplot process.
		#
		@pipe = IO.popen("gnuplot","w")
		
		#
		# Configure Gnuplot.
		#
		@pipe.puts "set terminal wxt"			# Nice GUI for plots.
		@pipe.puts "set termoption dashed"		# Needed for 'r--', 'r.-', 'r:'
		@pipe.puts "set termoption enhanced"	# Support superscripts + subscripts.
	end
	
	#
	# Command -- Send a raw command into Gnuplot.
	#            Gives the user more control over Gnuplot.
	#
	def cmd(str)
		@pipe.puts str
	end
	
	#
	# Settings -- Wrapper for 'set' command in Gnuplot.
	#
	def set(str)
		@pipe.puts "set #{str}"
	end
	
	#
	# Replot -- Wrapper for the 'replot' command in Gnuplot.
	#
	def replot
		@pipe.puts "replot"
	end
	
	#
	# 2D plotting -- Mostly like Gnuplot, but adding colours and line/point styles from Matlab.
	#
	def plot(*args)
		
		data = []
		all_plots = ''
		while args.length > 0
			#
			# NEXT PLOT
			#
			# First two values are the (x,y) points.
			data << args.shift
			data << args.shift
			
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
		nstreams = data.length / 2
		
		stream = (1..nstreams).map { |s|
			x = data.shift
			y = data.shift
			n = x.is_a?(Array) ? x.length - 1 : x.shape[0] - 1
			
			(0..n).map { |i| "#{x[i]}	#{y[i]}\n" }.join + "e\n"
		}.join
		
		@pipe.puts "plot #{all_plots} \n#{stream}"
	end
	
	###############################
	#
	#  PRIVATE METHODS
	#
	###############################
	
	private
	
	#
	# TODO: Can I avoid using strings here?
	#
	def finished(args)
		args.length == 0 or
					args[0].class.to_s == 'Array' or
					args[0].class.to_s == 'NMatrix'
	end
	
	#
	# - Get all the stye information for the next plot from 'args'.
	# - Return the styles as a string, and the remainder of 'args'.
	#
	def styles(args)
		
		g_with = ''
		m_with = ''
		str_index = 0
		this_plot = " '-' "
		while !finished(args)
			if args[0].is_a?(String)
				
				g_with << gnu_with(args[0]) 		if str_index == 0
				m_with << mat_with(args[0]) 		if str_index == 1
				
				this_plot << gnu_style(args.shift)	if str_index == 0
				this_plot << mat_style(args.shift)	if str_index == 1
				this_plot << tit_style(args.shift)	if str_index == 2
				
				str_index += 1
				
			elsif args[0].is_a?(Hash)
				opts = args.shift
				
				# Gnuplot style.
				g_with << gnu_with(opts[:g])			if opts[:g]
				g_with << gnu_with(opts[:gn])			if opts[:gn]
				g_with << gnu_with(opts[:gnu])			if opts[:gnu]
				g_with << gnu_with(opts[:gnup])			if opts[:gnup]
				g_with << gnu_with(opts[:gnupl])		if opts[:gnupl]
				g_with << gnu_with(opts[:gnuplo])		if opts[:gnuplo]
				g_with << gnu_with(opts[:gnuplot])		if opts[:gnuplot]
				
				this_plot << gnu_style(opts[:g])		if opts[:g]
				this_plot << gnu_style(opts[:gn])		if opts[:gn]
				this_plot << gnu_style(opts[:gnu])		if opts[:gnu]
				this_plot << gnu_style(opts[:gnup])		if opts[:gnup]
				this_plot << gnu_style(opts[:gnupl])	if opts[:gnupl]
				this_plot << gnu_style(opts[:gnuplo])	if opts[:gnuplo]
				this_plot << gnu_style(opts[:gnuplot])	if opts[:gnuplot]
				
				
				# Matlab style.
				m_with << mat_with(opts[:m])			if opts[:m]
				m_with << mat_with(opts[:ma])			if opts[:ma]
				m_with << mat_with(opts[:mat])			if opts[:mat]
				m_with << mat_with(opts[:matl])			if opts[:matl]
				m_with << mat_with(opts[:matla])		if opts[:matla]
				m_with << mat_with(opts[:matlab])		if opts[:matlab]
				
				this_plot << mat_style(opts[:m])		if opts[:m]
				this_plot << mat_style(opts[:ma])		if opts[:ma]
				this_plot << mat_style(opts[:mat])		if opts[:mat]
				this_plot << mat_style(opts[:matl])		if opts[:matl]
				this_plot << mat_style(opts[:matla])	if opts[:matla]
				this_plot << mat_style(opts[:matlab])	if opts[:matlab]
				
				# Title.
				this_plot << tit_style(opts[:t])		if opts[:t]
				this_plot << tit_style(opts[:ti])		if opts[:ti]
				this_plot << tit_style(opts[:tit])		if opts[:tit]
				this_plot << tit_style(opts[:titl])		if opts[:titl]
				this_plot << tit_style(opts[:title])	if opts[:title]
			end
			
		end
		
		
		# - The user may insert a 'with' in the gnuplot string which conflicts with matlab.
		# - In this case, the gnuplot string takes precdence.
		# - If you insert the word "with" in a title inside the gnuplot string... it's your
		#   own fault. I told you to put the title in the :title parameter.
		
		this_plot << g_with
		this_plot << m_with if g_with == ''
		
		#
		# If there is no title, add a blank one.
		#
		this_plot << " title '' " if this_plot !~ /tit/
		
		#
		# Return 'this_plot' and what is left of 'args'.
		#
		return this_plot, args
	end
	
	
	def gnu_with(s)
		s =~ /w/ ? s.scan(/([wW][iI]?[tT]?[hH]? +\w+)/).last.first : ''
	end
	def mat_with(s)
		wp = s =~ /[xsovdph<>+*^]/ ? true : false
		wl = s =~ /[-:.]/ ? true : false
		
		return " with linespoints " if wp and wl
		return " with points "		if wp
		return " with lines "       if wl
	end
	
	def tit_style(str)
		" title \"#{str}\" "
	end
	def gnu_style(str)
		str.gsub(/([wW][iI]?[tT]?[hH]? +\w+)/, '')
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
		style << " pt 8  " if mat =~ /</
		style << " pt 10 " if mat =~ />/
		style << " pt 4  " if mat =~ /p/
		style << " pt 7  " if mat =~ /h/
		
		# Line styles
		style << " lt 1 " if mat =~ /-/ and mat !~ /--/ and mat !~ /\.-/ and mat !~ /\.\.-/
		style << " lt 4 " if mat =~ /\.-/ and mat !~ /\.\.-/
		style << " lt 5 " if mat =~ /\.\.-/
		style << " lt 2 " if mat =~ /--/
		style << " lt 3 " if mat =~ /:/
		
		return style
	end
end


