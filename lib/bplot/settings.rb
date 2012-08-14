class BPlot
  module Settings
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def settings
        @__settings__ ||= []
      end

      def set(property)
        @__settings__ ||= []
        @__settings__ << [:set, property]
      end

      def unset(property)
        @__settings__ ||= []
        @__settings__ << [:unset, property]
      end
    end

    def settings
      @__settings__ ||= []
      self.class.settings + @__settings__
    end

    def set(property)
      @__settings__ ||= []
      @__settings__ << [:set, property]
    end

    def unset(property)
      @__settings__ ||= []
      @__settings__ << [:unset, property]
    end

    def apply(process)
      settings.each do |method, property|
        process.send method, property
      end
    end
  end

  class DefaultSettings
    include Settings
    #
    # Configure Gnuplot.
    #
    #set "terminal wxt"         # Nice GUI for plots.
    set "termoption dashed"    # Needed for 'r--', 'r.-', 'r:'
    set "termoption enhanced"  # Support superscripts + subscripts.
  end
end
