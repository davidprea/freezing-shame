require './monster'

class Spider < Monster
  
  def initialize
    super
  end
  
  def attack( opponent )
    if opponent.hasCondition?(:seized) || !self.hasAbility?(:seize_victim)
      @current_weapon_index = 1
    end
    super 
  end
  
  def hit opponent
    if self.weapon.name == "Ensnare"
      opponent.addCondition :seized
      FightRecord.addEvent( opponent, :seized, nil )
      if self.dice.tengwars > 0
        self.attack opponent
      end
    else
      super
    end
  end
      
  def self.weapons
    result = super
    result[:sting] = Weapon.new( "Sting", 0, 10, 14, 0, :attribute, :poison )
    result[:attribute_beak] = Weapon.new("Beak", 0, 8, 18, 0, :attribute, :poison )
    result[:stomp] = Weapon.new("Stomp", 0, 12, 14, 0, :attribute, :knockdown )
    result[:beak] = Weapon.new("Beak", 6, 12, 15, 0, :body, :poison )
    result[:ensnare] = Weapon.new("Ensnare", 0, 0, 0, 0, :body, :unimplemented )
    result
  end
  
  def self.abilities
    result = super
    result[:foul_reek] = { :name => "Foul Reek", :tooltip => "Unimplemented."}
    result[:countless_children] = { :name => "Countless Children", :tooltip => "Unimplemented."}
    result[:webs_of_illusion] = { :name => "Webs of Illusion", :tooltip => "Unimplemented."}
    result[:many_poisons] = { :name => "Many Poisons", :tooltip => "Unimplemented."}
    result
  end
    
  
  def self.types
    result = {}
    result[:attercop] = { :name => "Attercop", :attribute_level => 4, :size => 1, :endurance => 12, :hate => 2, :parry => 4, :armor => 2, :shield => 0, :weapons => [{:type=>:ensnare,:skill=>2,:favoured=>true},{ :type=>:sting,:skill => 2, :favoured=>true}], :abilities => [:great_leap, :seize_victim] }
    result[:great_spider] = { :name => "Great Spider", :attribute_level => 4, :size => 3, :endurance => 36, :hate => 3, :parry => 5, :armor => 3, :shield => 0, :weapons => [{:type=>:ensnare,:skill=>3,:favoured=>true},{ :type=>:sting,:skill => 2,:favoured=>true}], :abilities => [:strike_fear, :seize_victim, :denizen_of_the_dark, :dreadful_spells] }
    result[:sarqin] = { :name => "Sarqin, the Mother-of-All", :unique => true, :attribute_level => 8, :size => 3, :endurance => 90, :hate => 8, :parry => 5, :armor => 3, :shield => 0, :weapons => [{ :type=>:attribute_beak,:skill => 4}, {:type=>:ensnare,:skill => 3}], :abilities => [:great_size, :thick_hide, :seize_victim, :thing_of_terror, :foul_reek, :countless_children ]}
    result[:tauler] = { :name => "Tauler, the Hunter", :unique => true, :attribute_level => 7, :size => 3, :endurance => 60, :hate => 8, :parry => 8, :armor => 3, :shield => 0, :weapons => [{ :type=>:attribute_beak,:skill => 5}, {:type=>:stomp,:skill => 3 }], :abilities => [:great_size, :horrible_strength, :hideous_toughness, :strike_fear] }
    result[:tyulqin] = { :name => "Tyulqin, the Weaver", :unique => true, :attribute_level => 9, :size => 3, :endurance => 60, :hate => 8, :parry => 7, :armor => 3, :weapons => [{ :type=>:attribute_beak,:skill => 4}, {:type=>:ensnare,:skill => 3}], :abilities => [:great_size, :seize_victim, :strike_fear, :dreadful_spells, :webs_of_illusion, :many_poisons]}
    result[:hunter] = { :name => "Hunter Spider", :attribute_level => 4, :size => 3, :endurance => 25, :hate => 3, :parry => 6, :armor => 3, :shield => 0, :weapons => [{ :type=>:beak,:skill => 2}], :abilities => [:great_leap, :horrible_strength] }
    
    result
  end
end

Monster.register Spider

