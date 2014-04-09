require './monster'

class Troll < Monster
  
  def initialize
    super
  end
  
  
  def self.weapons
    result = super
    result[:bite] = Weapon.new( "Bite", 5, 12, 14, 0, :body, nil );
    result[:club] = Weapon.new( "Club", 6, 10, 14, 0, :one_handed, nil );
    result[:crush] = Weapon.new( "Crush", 0, 12, 12, 0, :attribute, nil );
    result[:heavy_hammer] = Weapon.new( "Heavy hammer", 8, 12, 16, 0, :one_handed, :break_shield );
    result
  end
  
  def self.types
    result = {}
    result[:cave] = { :name => "Cave Troll", :attribute_level => 7, :size => 3, :endurance => 76, :hate => 8, :parry => 5, :armor => 3, :shield => 0, :weapons => [{ :type=>:bite,:skill => 3}, {:type=>:crush,:skill => 1,:favoured=>true}], :abilities => [:great_size, :hideous_toughness, :savage_assault, :thick_hide] }
    
    result[:hill] = { :name => "Hill Troll", :attribute_level => 7, :size => 3, :endurance => 84, :hate => 7, :parry => 5, :armor => 3, :shield => 1, :weapons => [{:type => :heavy_hammer, :skill => 3}, {:type=>:crush, :skill => 2}], :abilities => [:great_size, :hideous_toughness, :thick_hide] }
    
    result[:hill_chief] = { :name => "Hill Troll Chief", :attribute_level => 8, :size => 3, :endurance => 90, :hate => 10, :parry => 6, :armor => 4, :shield => 1, :weapons => [{ :type => :heavy_hammer, :skill => 4,:favoured=>true}, {:type => :bite, :skill => 2,:favoured=>true}], :abilities => [:great_size, :hideous_toughness, :horrible_strength, :no_quarter] }
    
    result[:mountain] = { :name => "Mountain Troll", :attribute_level => 9, :size => 3, :endurance => 96, :hate => 9, :parry => 7, :armor => 4, :shield => 0, :weapons => [{:type => :crush, :skill => 4, :favoured=>true}], :abilities => [:great_size, :hideous_toughness, :horrible_strength, :thing_of_terror] }
    
    result[:stone] = { :name => "Stone Troll", :attribute_level => 6, :size => 3, :endurance => 72, :hate => 5, :parry => 5, :armor => 3, :shield => 0, :weapons => [{ :type => :club, :skill => 3},{:type => :crush, :skill => 1,:favoured=>true}], :abilities => [:great_size, :horrible_strength, :dwarf_hatred] }
    
    result
  end
  
end

Monster.register Troll

