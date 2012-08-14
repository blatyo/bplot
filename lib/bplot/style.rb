class BPlot
  class Style
    def initialize(style = {})
      @style = style

      if block_given?
        convert_to_hash

        yield self
      end
    end

    def title(title)
      convert_to_hash
      @style[:title] = title
    end

    def color(color)
      convert_to_hash
      @style[:color] = color
    end

    def lines(lines)
      convert_to_hash
      @style[:lines] = lines
    end

    def points(points)
      convert_to_hash
      @style[:points] = points
    end

    def to_s
      parse_style(@style)
    end

  private

    def convert_to_hash
      @style = @style.is_a?(Hash) ? @style : {}
    end

    def parse_style(style)
      title = ''
      color = ''
      output = " '-' "
      
      case style
      when String
        style = style.split(/;/)
        
        #
        # Gnuplot 'with' beats Matlab's.
        #
        with = gnu_with(style[2]) if style[2]
        with = mat_with(style[0]) if with
        
        output << mat_style(style[0])
        output << gnu_style(style[2]) if style[2]
        
        title = style[1] if style.length >= 1
      when Hash
        title  = style[:title]  if style[:title]
        color  = style[:color]  if style[:color]
        
        #
        # Infer the 'with' command for :lines and :points.
        #
        if style[:lines]
          lw, lt = style[:lines].split(/;/)
          
          lw = lw.to_i
          lw = 1  if lw <= 0
          
          lt = 1  if lt == '' or lt == nil
          lt = 1  if lt.to_s =~ /solid/i
          lt = 2  if lt.to_s =~ /dashed/i
          lt = 3  if lt.to_s =~ /dot/i
          lt = 4  if lt.to_s =~ /dot-dashed/i
          lt = 5  if lt.to_s =~ /dot-dot-dashed/i
          
          output << " lw #{lw} " if lw.is_a?(Fixnum)
          output << " lt #{lt} " if lt.is_a?(Fixnum)
        end

        if style[:points]
          ps, pt = style[:points].split(/;/)
          
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
          
          output << " ps #{ps} " if ps.is_a?(Fixnum)
          output << " pt #{pt} " if pt.is_a?(Fixnum)
        end
        
        #
        # "with" strings from both Matlab and Gnuplot take precedence.
        #
        # In other words:  Gnuplot > Matlab > Named parameters. 
        #
        if with == ''
          with = 'with lines'       if style[:lines]
          with = 'with points'      if style[:points]
          with = 'with linespoints' if style[:lines] and style[:points]
        end
      end
      
      
      #
      # Finish up the command (title, colour, 'with', etc).
      #
      output << " lc rgb \"#{color}\" " if color != ''
      output << " title  \"#{title}\" "
      output << with if with
      
      return output
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
      return " with points "      if wp
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
end