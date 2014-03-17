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
  
  # use this for cloning equipment
  def clone( newname=nil )
    w = Weapon.new( (newname ? newname : @name ), @damage, @edge, @injury, @encumbrance, @type, @called_shot_effect)
    w.qualities = @qualities.dup
    w
  end
  
  def qualityList
    [:grievous, :keen, :fell] # implemented by subclasses; list of all possible qualities
  end
  
  
  def rollModifier
    if( @qualities.include? :dalish_longbow)
      return -1
    end
    0
    # have to update this for different special weapons
  end
  
  def allows_shield?
    (@type == :one_handed) || (@type == :versatile)
  end
  
  def self.fist
    Weapon.new( "Unarmed", 1, 13, 0, 0, :unarmed, nil)
  end
  
  def damage
    (@qualities.include? :grievous) ? @damage + 2 : @damage
  end
  
  def edge
    (@qualities.include? :keen) ? [(@edge-1),10].min : @edge
  end
  
  def injury
    (@qualities.include? :fell) ? @injury + 2 : @injury
  end
end
