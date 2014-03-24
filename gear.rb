#require 'sinatra'
#require 'dm-sqlite-adapter'
#require 'data_mapper'

#require './opponent'

#DataMapper::setup(:default, 'sqlite3::memory')

require './equipment'

class Gear < Equipment
  
  attr_accessor :value
  
  def self.none
    self.new( "None", 0, 0 )
  end
  
  def reset
    if( rand() < 0.3 )  
      @value = @undamaged_value
    end
  end
  
  def addQuality( symbol ) 
    if [:cunning_make_armor, :cunning_make_shield, :cunning_make_helm ].include? symbol
      self.addQUality :cunning_make
      return
    end
    
    super
    case symbol
    when :cunning_make
      @encumbrance = [@encumbrance-2,0].max
    end
    true
  end    
  

  
  def value=(newValue)
    if !newValue
      puts "#{self.class} received a value of nil"
    end
    @value = newValue
    @undamaged_value = @value
  end

  
  def takeDamage amount=1
    if !@undamaged_value
      @undamaged_value = @value
    end
    @value = [@value-amount,0].max
  end
   
  def encumbrance
    @encumbrance
  end
  
  def initialize( name, value, encumbrance )
    super( name, encumbrance )
    self.value = value # prot for armor and helms, parry for shields
  end
  
  # use this for cloning equipment
  def clone( newname = nil )
    result = self.class.new( (newname ? newname : @name), @value, @encumbrance )
    @qualities.each do |q|
      result.addQuality q
    end
    result
  end  
end

class Protection < Gear
  
  def addQuality( symbol ) 
    super
    case symbol
    when :close_fitting
    when :reinforced
      @value += 1
    end
    true
  end    
  
  
  
  
end

class Armor < Protection
  
  
  def qualityList
    [:cunning_make_armor, :close_fitting_armor] 
  end
  
  def value
    return super + ((self.hasQuality? :close_fitting_armor) ? 1 : 0 )
  end
  
end 

class Helm < Protection
  def qualityList
    [:cunning_make_helm, :close_fitting_helm] 
  end
  
  def value
    return super + ((self.hasQuality? :close_fitting_helm) ? 1 : 0 )
  end
  

  

end

class Shield < Gear
  
  attr_accessor :is_broken
  
  def is_broken=(newbroken)
    if !(@qualities.include? :reinforced) || newbroken # if it's not reinforced, or new value is true
      @is_broken=(newbroken)
    end
    @is_broken
  end
    
  
  def qualityList
    [:cunning_make_shield, :reinforced] # implemented by subclasses; list of all possible qualities
  end
  
  
  def value
    if is_broken 
      0
    else
      super
    end
  end
  
  # use this for cloning equipment
  def clone( newname = nil )
    result = super( newname )
    result.is_broken = false
    result
  end
  
  
#  def initialize( name, value, encumbrance )
#    super
#    @is_broken = false
#  end
end
  
  