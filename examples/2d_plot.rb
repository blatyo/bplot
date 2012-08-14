require 'bplot'

BPlot.session do |plotter|
  plotter.plot do |plot|
    xs = (-10..10).to_a
    ys = xs.map{|x| x**2}
    zs = xs.map{|x| x**3}

    plot.data_set(xs, ys) do |style|
      style.title 'x^2' 
      style.color 'red'
      style.lines '1;solid'
      style.points '1;+'
    end

    plot.data_set(xs, zs) do |style|
      style.title 'x^3' 
      style.color 'blue'
      style.lines '1;dashed'
      style.points '1;x'
    end    
  end
end