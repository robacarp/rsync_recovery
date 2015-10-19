class Hash
  def & hsh
    keys = hsh.keys
    self.select do |k,v|
      keys.include? k
    end
  end

  def - hsh
    keys = hsh.keys
    self.reject do |k,v|
      keys.include? k
    end
  end
end
