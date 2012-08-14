class BPlot
  class DataSet
    include Enumerable

    def initialize(*dimensions)
      @dimensions = dimensions
    end

    def each
      iterators = @dimensions.map(&:each)

      yield iterators.map(&:next) while true
    rescue StopIteration
      # No more elements
    end

    #
    # Genertes a stream of data for closed by 'e' ("end").
    #
    def to_s
      map{|*dimensions| dimensions.join(' ') << "\n"}.join << "e\n"
    end
  end
end
