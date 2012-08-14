class BPlot
  class Process
    def initialize
      @pipe = IO.popen("gnuplot -p", "w")
    end

    #
    # === Issue raw command
    #
    # Send a raw command to the Gnuplot backend.
    # This gives the user more control over plotting engine.
    #
    # === Example
    #
    #   p = BPlot::Process.new
    #   p.cmd('plot sin(x)')
    #
    def cmd(str)
      @pipe.puts str.to_s
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
    #   p.set('terminal enhanced postscript color')
    #   p.set('output "myplot.ps"')
    #   p.set('xrange [0:10]')
    #   p.set('yrange [0:50]')
    #   p.set('xlabel "This is the X Axis"')
    #   p.set('ylabel "This is the Y Axis"')
    #   p.set('title "A title for the whole plot"')
    #
    def set(str)
      cmd "set #{str}"
    end

    # === Settings
    #
    # This method is a thin wrapper around the Gnuplot "unset" command.
    # It is used to reset settings back to their default values. See
    # the documentation on "set" for more information. See also the
    # Gnuplot documentaion for "set" and "unset".
    def unset(str)
      cmd "unset #{str}"
    end

    # === Show
    #
    # The `set` command can be used to set *lots* of options.  No screen is
    # drawn, however, until a plotting command is given. The *show* command
    # shows their settings; show('all') shows all the settings.
    #
    def show(str)
      cmd "show #{str}"
    end

    # === Plotting
    #
    # This method is a thin wrapper around the Gnuplot "plot" command.
    # It is used to plot data. See the documentation on "plot" for more
    # information.
    #
    def plot(str)
      cmd "plot #{str}"
    end

    def splot(str)
      cmd "splot #{str}"
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
    #   p.set('terminal postscript')
    #   p.set('output "myplot.ps"')
    #   p.refresh
    #
    #   p.set('terminal png')
    #   p.set('output "myplot.png"')
    #   p.refresh
    #
    def refresh
      cmd "refresh"
    end

    def close
      cmd "exit"
    end
  end
end
