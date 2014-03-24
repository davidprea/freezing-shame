#require 'sinatra'
#require 'dm-sqlite-adapter'
#require 'data_mapper'

#require './opponent'

#DataMapper::setup(:default, 'sqlite3::memory')

require './equipment'

class Weapon < Equipment
  
  attr_accessor :name, :damage, :edge, :injury, :encumbrance, :type, :called_shot_effect
  
  #need to add something about ranged or melee? and how it is being used if either?

  def initialize( name, damage, edge, injury, encumbrance, type, called_shot_effect )
    super( name, encumbrance )
    @damage = damage
    @edge = edge
    @injury = injury
    @type = type
    @called_shot_effect = called_shot_effect
  end
  
  def to_s
    @name + "( dmg: " + @damage.to_s + ", edge: " + @edge.to_s + ", inj: " + @injury.to_s + " )" + (@qualities.size > 0 ? (", q: " + @qualities.to_a.join(",")) : "" )
  end
  
  # use this for cloning equipment
  def clone( newname=nil )
    w = Weapon.new( (newname ? newname : @name ), @damage, @edge, @injury, @encumbrance, @type, @called_shot_effect)
    @qualities.each do |q|
      w.addQuality q
    end
    w
  end
  
  def qualityList
    [:grievous, :keen, :fell] # implemented by subclasses; list of all possible qualities
  end
  
  def addQuality( symbol ) 
    super
    case symbol
    when :grievous
      @damage += 2
    when :keen
      @edge = [@edge-1,10].min
    when :fell
      @injury += 2
    end
  end  
  
  def type=(newTYpe)
    @type = newType
    @allows_shield = (@type == :one_handed) || (@type == :versatile)
  end
  
  def protectionModifier
    if( @qualities.include? :dalish_longbow)
      return -1
    end
    0
    # have to update this for different special weapons
  end
  
  def allows_shield?
    (@allows_shield ? @allows_shield : false) # default to false if @allows_shield not defined
  end
  
  def self.fist
    Weapon.new( "Unarmed", 1, 13, 0, 0, :unarmed, nil)
  end
  

end
