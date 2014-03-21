require './monster'

class Orc < Monster
  
  def initialize
    super
  end
  
  
  def self.armors
    result = super
    result[:orc_armor] = Armor.new("Orc armor", 3, 0)
    return result
  end
  
  def self.weapons
    result = super
    result[:bent_sword] = Weapon.new( "Bent Sword", 4, 10, 12, 0, :one_handed, :disarm );
    result[:bow_of_horn] = Weapon.new( "Bow of Horn", 4, 10, 12, 0, :ranged, :poison)
    result[:broad_bladed_sword] = Weapon.new("Broad-bladed Sword", 5, 10, 14, 0, :one_handed, :poison)
    result[:broad_headed_spear] = Weapon.new("Broad-headed Spear", 5, 10, 12, 0, :one_handed, :pierce)
    result[:heavy_scimitar] = Weapon.new("Heavy Scimitar", 7, 10, 14, 0, :two_handed, :break_shield)
    result[:orc_axe] = Weapon.new( "Orc-axe", 5, 12, 16, 0, :one_handed, :break_shield );
    result[:spear] = Weapon.new("Spear", 4, 9, 12, 0, :versatile, :pierce)
    result[:jagged_knife] = Weapon.new("Jagged Kinfe", 3, 12, 14, 0, :one_handed, :nil)
    result[:stone_spear] = Weapon.new("Stone Spear", 4, 10, 12, 0, :one_handed, :pierce)
    result
  end
  
  def self.types
    result = {}
    result[:goblin_archer] = { :name => "Goblin Archer", :size => 1, :attribute_level => 2, :endurance => 8, :hate => 1, :parry => 2, :shield => 0, :armor => 2, :weapons => [{ :type=>:bow_of_horn,:skill => 2}, {:type=>:jagged_knife,:skill => 1 }], :abilities => [:hate_sunlight, :denizen_of_the_dark, :craven],
    :optional_abilities => [:dwarf_hatred, :hobbit_hatred] }
    
    result[:orc_guard] = 
    { 
      :name => "Orc Guard", 
      :size => 2, 
      :attribute_level => 4, 
      :endurance => 16, 
      :hate => 3, 
      :parry => 4, 
      :shield => 2, 
      :armor => 2, 
      :weapons => [
        { :type=>:spear,:skill => 3}, 
        {:type=>:bent_sword,:skill => 2 }], 
      :abilities => [:hate_sunlight, :hideous_toughness],
      :optional_abilities => [:dwarf_hatred, :hobbit_hatred] }

    result[:orc_soldier] = 
    { 
      :name => "Orc Soldier", 
      :size => 2, 
      :attribute_level => 3, 
      :endurance => 12, 
      :hate => 1, 
      :parry => 3, 
      :shield => 1, 
      :armor => 3, 
      :weapons => [
        { :type=>:spear,:skill => 2}, 
        {:type=>:bent_sword,:skill => 2 }], 
      :abilities => [:hate_sunlight, :craven],
      :optional_abilities => [:dwarf_hatred, :hobbit_hatred] }    
      
      result[:chieftan] = { :name => "Orc Chieftan", :attribute_level => 5, :endurance => 20, :size => 2, :hate => 5, :parry => 4, :armor => 3, :shield => 3, :weapons => [{:type => :orc_axe, :skill => 3}], :abilities => [:hate_sunlight, :snake_like_speed, :horrible_strength, :commanding_voice],
    :optional_abilities => [:dwarf_hatred, :hobbit_hatred] }
    result[:great] = { :name => "Great Orc", :attribute_level => 7, :endurance => 48, :size => 3, :hate => 8, :parry => 5, :armor => 4, :shield => 2, :weapons => [{:type => :heavy_scimitar, :skill => 3}, {:type => :broad_headed_spear, :skill=>3}, {:type => :orc_axe, :skill=>2}], :abilities => [:horrible_strength, :commanding_voice, :hideous_toughness, :great_size]}
    result[:snaga_tracker] = { :name => "Snaga Tracker", :attribute_level => 2, :size => 1, :endurance => 8, :hate => 2, :parry => 3, :armor => 2, :shield => 0, :weapons => [{ :type => :bow_of_horn, :skill => 2}, {:type => :jagged_knife,:skill => 2 }], :abilities => [:hate_sunlight, :snake_like_speed]}
    result[:black_uruk] = { :name => "Black Uruk", :attribute_level => 5, :size => 2, :endurance => 20, :hate => 4, :parry => 5, :armor => 2, :shield => 2, :weapons => [{ :type=>:broad_bladed_sword,:skill => 2}, {:type=>:broad_headed_spear,:skill => 2 }], :abilities => [:horrible_strength] }
    result[:messenger_of_lugburz] = { :name => "Messenger of Lugburz", :size => 2, :attribute_level => 4, :endurance => 18, :hate => 5, :parry => 4, :armor => 2, :weapons =>  [{:type=>:heavy_scimitar,:skill => 2}, {:type=>:jagged_knife,:skill => 3}], :abilities => [:hate_sunlight, :snake_like_speed, :commanding_voice]}


    result[:forest_goblin] = { :name => "Forest Goblin", :size => 1, :attribute_level => 2, :endurance => 10, :hate => 2, :parry => 2, :shield => 1, :armor => 2, :weapons => [{ :type=>:stone_spear,:skill => 2}, {:type=>:jagged_knife,:skill => 1 }], :abilities => [:hate_sunlight, :horrible_strength, :mirkwood_dweller, :craven] }



    result
  end
  
  
  def self.chieftan
    o = Orc.new
    o.name = "Orc Chieftan"
    o.attribute_level = 5
    o.max_endurance = 20
    o.max_hate = 5
    o.parry = 4
    o.shield = :shield
    o.armor = :orc_armor
    o.helm = :none
    o.weapon = :orc_axe
    o.weapon_skill = 3
    return o
  end

end

Monster.register Orc

