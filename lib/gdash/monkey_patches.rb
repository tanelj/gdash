class Object
  def to_query(key)
    "#{key.to_s}=#{to_s}"
  end
end

class Array
  def in_groups_of(chunk_size, padded_with=nil)
    if chunk_size <= 1
      if block_given?
        self.each{|a| yield([a])}
      else
        self
      end
    else
      arr = self.clone

      # how many to add
      padding = chunk_size - (arr.size % chunk_size)
      padding = 0 if padding == chunk_size

      # pad at the end
      arr.concat([padded_with] * padding)

      # how many chunks we'll make
      count = arr.size / chunk_size

      # make that many arrays
      result = []
      count.times {|s| result <<  arr[s * chunk_size, chunk_size]}

      if block_given?
        result.each{|a| yield(a)}
      else
        result
      end
    end
  end

  def to_query(key)
    prefix = "#{key}[]"
    collect { |value| value.to_query(prefix) }.join '&'
  end
end

class Hash
  def to_param(namespace = nil)
    collect do |key, value|
      if value.is_a?(Hash)
        value.to_param(key)
      else
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.sort * '&'
  end
end

class GraphiteGraph
  attr_accessor :properties, :file
end
