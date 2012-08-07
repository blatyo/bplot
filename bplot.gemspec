Gem::Specification.new do |gem|
  gem.name        = 'bplot'
  gem.version     = '0.0.1'
  gem.date        = '2012-08-07'
  gem.summary     = 'A ploting module for SciRuby with a Gnuplot backend.'
  gem.description = 'A 2D and 3D plotting module for SciRuby that uses syntax from Gnuplot and to a lesser degree Matlab.'
  gem.authors     = ["Daniel Carrera"]
  gem.email       = 'dcarrera@gmail.com'
  gem.files       = ["README", "LICENSE", "lib/bplot.rb"]
  gem.homepage    = 'http://rubygems.org/gems/bplot'
  gem.post_install_message = <<-EOF
***********************************************************
Welcome to BPlot: A plotting module for SciRuby!

                 \\     /
             \\    o ^ o    /
               \\ (     ) /
    ____________(%%%%%%%)____________
   (     /   /  )%%%%%%%(  \\   \\     )
   (___/___/__/           \\__\\___\\___)
      (     /  /(%%%%%%%)\\  \\     )
       (__/___/ (%%%%%%%) \\___\\__)     This is a bee.
               /(       )\\             I like bees.
             /   (%%%%%)   \\
                  (%%%)
                    !

              *** WARNING ***

BPlot is in ALPHA status. Two dimmensional plots seem to work
well but they really need more testing. Surface plots and some
other features are not implemented yet.

BPlot uses Gnuplot as the plotting engine, so you need to have
Gnuplot installed and in your PATH. BPlot lets you use straight
Gnuplot commands, but it also borrows some useful style syntax
from Matlab to make plotting even better.

BPlot can work with either NMatrix objects or with plain Ruby
arrays. Try some of the commands below to get a feel of how
it works:

require 'bplot'

x = [1,2,3,4,5]
y = [1,4,9,16,25]
z = [25,20,15,10,5]

b = BPlot.new

# Send a raw command into Gnuplot.
b.cmd('plot sin(x) title "Plot without Ruby."')

# Gnuplot 'set' command.
b.set('xrange [0:6]')
b.set('yrange [0:30]')
b.set('title "Heading for the entire plot"')

# Gnuplot 'replot' command.
b.replot

# Basic plots.
b.plot(x, y)
b.plot(x, y, 'ps 2', 'rh')
b.plot(x, y, 'ps 2', 'rh--', 'y = x^2')

# The 'with' command on the gnuplot string takes precedence.
b.plot(x, y, 'ps 2 w lp', 'rh')
b.plot(x, y, 'ps 2 with steps', 'rh')

# Named parameters.
b.plot(x, y, :title => 'Mass', :gnuplot => 'ps 1.5', :matlab => 'rh-')
b.plot(x, y, :t => 'Mass', :g => 'ps 2.5', :m => 'rh-')

# Multiple data sets (need not be the same length).
b.plot(x, y, 'ps 2', 'rh-', x, z, 'ps 1.5', 'bs--')
b.plot(x, y, 'ps 2', 'rh-', 'Quadratic', x, z, 'ps 1.5', 'bs--', 'Linear')

# Named parameters only allowed for the last data set.
b.plot(x, y, 'ps 2', 'rh-',       'Quadratic', x, z, 'ps 1.5', 'bs--', :t => 'Linear') # OK.
b.plot(x, y, 'ps 2', 'rh-', :t => 'Quadratic', x, z, 'ps 1.5', 'bs--',       'Linear') # ERROR.

***********************************************************
EOF
end