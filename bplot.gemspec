Gem::Specification.new do |gem|
  gem.name        = 'bplot'
  gem.version     = '0.0.2.2'
  gem.date        = '2012-08-11'
  gem.summary     = 'A ploting module for SciRuby with a Gnuplot backend.'
  gem.description = 'A 2D and 3D plotting module for SciRuby that uses syntax from Gnuplot and to a lesser degree Matlab.'
  gem.authors     = ["Daniel Carrera"]
  gem.email       = 'dcarrera@gmail.com'
  gem.files       = ["README", "LICENSE", "Tutorial","ChangeLog","Roadmap", "lib/bplot.rb"]
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
well but they really need more testing. Many features such as
surface plots have not been implemented yet. The backend uses
Gnuplot, so you must have Gnuplot installed and in your PATH.

The plotting command mixes Matlab and Gnuplot syntax. The addition
of Matlab syntax to Gnuplot makes plotting immensely easier while
still retaining the power of Gnuplot. BPlot provides a comfortable
environment for Matlab and Gnuplot users. Matlab users will learn
some Gnuplot and Gnuplot users will leran some Matlab.

Don't forget to read the tutorial!

BPlot comes with a nice tutorial that documents every feature.
If you don't have a copy of the tutorial, you can get one here:

https://github.com/dcarrera/bplot/blob/master/Tutorial


***********************************************************
EOF
end