class Equipment
  
  require 'set'
  
  #ugh...Equipment.qualities works just like Opponent.feats...have to refactor at some point
  
  attr_accessor :encumbrance, :name
  
  def initialize( name, encumbrance )
    @name = name
    @encumbrance = encumbrance
  end
  
  # use this for cloning equipment
  
  def self.displayName
    self.to_s
  end
  
  def qualities
    if !@qualities
      @qualities = Set.new
    end
    @qualities
  end
  
  def name2sym
    @name.gsub(/[^a-zA-Z\d\s-]/,"").gsub(/[-\s]/,'_').downcase.to_sym
  end
  
  def addParams params
    if @name == "None"
      return
    end
    
    params.keys.each do |key|
      symbol = key.to_sym
      if (self.qualityList.include? symbol)
        self.addQuality symbol
      end
    end
  end
  
  def hasQuality? symbol
    self.qualities.include? symbol
  end
  
  def addQuality symbol  
    self.qualities.add symbol
    # overrride in subclasses to modify stats
  end    
  

  def self.to_sym
    :equipment
  end
  
end

class Modifier < Equipment
  # this is a total hack to allow cultural rewards that modify equipment...
end
