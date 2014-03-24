class Equipment
  
  require 'set'
  
  #ugh...Equipment.qualities works just like Opponent.feats...have to refactor at some point
  
  attr_accessor :encumbrance, :name
  
  def initialize( name, encumbrance )
    @name = name
    @encumbrance = encumbrance
    @qualities = Set.new # ahhhh....forget bit masks and just keep an array
  end
  
  # use this for cloning equipment
  
  def self.displayName
    self.to_s
  end
  
  def name2sym
    @name.gsub(/[^a-zA-Z\d\s-]/,"").gsub(/[-\s]/,'_').downcase.to_sym
  end
  
  def addParams params
    params.keys.each do |key|
      if (params[key] == "on") && (self.qualityList.include? key.to_sym)
        self.addQuality key.to_sym
      end
    end
  end
  
  def hasQuality? symbol
    @qualities.include? symbol
  end
  
  def addQuality( symbol ) 
    @qualities.add symbol
    # overrride in subclasses to modify stats
  end    
  

  def self.to_sym
    :equipment
  end
  
end

class Modifier < Equipment
  # this is a total hack to allow cultural rewards that modify equipment...
end
