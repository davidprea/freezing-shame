require './monster'

class Spider < Monster
  
  def initialize
    super
    puts "Spider initializing"
  end
      
  def self.weapons
    result = super
    result[:sting] = Weapon.new( "Sting", 0, 10, 14, 0, :attribute, :poison )
    result[:beak] = Weapon.new("Beak", 0, 8, 18, 0, :attribute, :poison )
    result[:stomp] = Weapon.new("Stomp", 0, 12, 14, 0, :attribute, :knockdown )
    result
  end
  
  def self.types
    result = {}
    result[:attercop] = { :name => "Attercop", :attribute_level => 4, :endurance => 12, :hate => 2, :parry => 4, :armor => 2, :shield => 0, :weapons => { :sting => 2}, :abilities => [:great_leap, :seize_victim] }
    result[:great_spider] = { :name => "Great Spider", :attribute_level => 4, :endurance => 36, :hate => 3, :parry => 5, :armor => 3, :shield => 0, :weapons => { :sting => 2}, :abilities => [:strike_fear, :seize_victim, :denizen_of_the_dark, :dreadful_spells] }
    result[:sarqin] = { :name => "Sarqin, the Mother-of-All", :attribute_level => 8, :endurance => 90, :hate => 8, :parry => 5, :armor => 3, :shield => 0, :weapons => { :beak => 4, :ensnare => 3 }, :abilities => [:great_size, :thick_hide, :seize_victim, :thing_of_terror, :foul_reek, :countless_children ]}
    result[:tauler] = { :name => "Tauler, the Hunter", :attribute_level => 7, :endurance => 60, :hate => 8, :parry => 8, :armor => 3, :shield => 0, :weapons => { :beak => 5, :stomp => 3 }, :abilities => [:great_size, :horrible_strength, :hideous_toughness, :strike_fear] }
    result[:tyulqin] = { :name => "Tyulqin, the Weaver", :attribute_level => 9, :endurance => 60, :hate => 8, :parry => 7, :armor => 3, :weapons => { :ensnare => 3, :beak => 4}, :abilities => [:great_size, :seize_victim, :strike_fear, :dreadful_spells, :webs_of_illusion, :many_poisons]}
    result
  end
end

Monster.register Spider
