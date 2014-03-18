require './monster'

class Wolf < Monster
  
  def initialize
    super
  end
      
  def self.weapons
    result = super
    result[:bite] = Weapon.new( "Bite", 0, 10, 14, 0, :attribute, :pierce )
    result[:rend] = Weapon.new("Rend", 0, 12, 14, 0, :attribute, :nil )
    result
  end
  
  def self.types
    result = {}
    result[:wild] = { 
      :name => "Wild Wolf", 
      :attribute_level => 3, 
      :size => 2, 
      :endurance => 12, 
      :hate => 1, 
      :parry => 5, 
      :armor => 2, 
      :shield => 0, 
      :weapons => 
        [
          { :type=>:bite, :skill => 2}
        ], 
      :abilities => [:great_leap, :seize_victim, :fear_of_fire] 
    }

    result[:leader] = { 
      :name => "Wolf Leader", 
      :attribute_level => 5, 
      :size => 2, 
      :endurance => 16, 
      :hate => 3, 
      :parry => 6, 
      :armor => 3, 
      :shield => 0, 
      :weapons => 
        [
          { :type=>:bite, :skill => 3},
          { :type=>:rend, :skill => 1}
        ], 
      :abilities => [:savage_assault, :strike_fear, :fear_of_fire] 
    }

    result[:hound_of_sauron] = { 
      :name => "Hound of Sauron", 
      :attribute_level => 6, 
      :size => 2, 
      :endurance => 20, 
      :hate => 5, 
      :parry => 6, 
      :armor => 3, 
      :shield => 0, 
      :weapons => 
        [
          { :type=>:bite, :skill => 3},
          { :type=>:rend, :skill => 1}
        ], 
      :abilities => [:savage_assault, :strike_fear, :hideous_toughness] 
    }
    
    result[:werewolf_of_mirkwood] = { 
      :name => "Werewolf of Mirkwood", 
      :unique => true,
      :attribute_level => 8, 
      :size => 3, 
      :endurance => 68, 
      :hate => 12, 
      :parry => 9, 
      :armor => 4, 
      :shield => 0, 
      :weapons => 
        [
          { :type=>:bite, :skill => 4},
          { :type=>:rend, :skill => 1}
        ], 
      :abilities => [ :savage_assault, :thing_of_terror, :denizen_of_the_dark, :great_leap, :great_size ] 
    }
    
    
    result
  end
end

Monster.register Wolf

