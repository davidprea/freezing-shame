#class Weapon
#  String  name
#  Number  damage
#  Number  edge
#  Number  injury
#end

require './opponent'

class Monster < Opponent  
  
  @@monsters = nil
  
  attr_accessor :attribute_level, :parry, :hate, :abilities, :optional_abilities
  attr_accessor :current_hate
  attr_accessor :sauron_rule, :unique, :favoured_skills_rule
    
  def initialize
    super
    @parry = 0
    @attribute_level = 1
    @abilities = {}
    @unique = false
    @sauron_rule = false
    @hate = 0
    @current_weapon_index = 0
    @optional_abilities = Hash.new
  end
  
  def self.abilities
    {
      :horrible_strength => { :name => "Horrible Strength", :tooltip => "Spend hate to increase damage by attribute-level. (50% chance per hit.)" },
      :hideous_toughness => { :name => "Hideous Toughness", :tooltip => "Spend hate to reduce damage by attribute-level when damage >= attribute_level."},
      :great_size => { :name => "Great Size", :tooltip => "Requires two wounds, or one wound and zero endurance, to kill."},
      :hate_sunlight => { :name => "Hate Sunlight", :tooltip => "Unimplemented."},
      :savage_assault => { :name => "Savage Assault", :tooltip => "On great or extraordinary success, roll second attack with alternate weapon."},
      :seize_victim => { :name => "Seize Victim", :tooltip => "Unimplemented."},
      :fear_of_fire => { :name => "Fear of Fire", :tooltip => "Unimplemented."},
      :thick_hide => { :name => "Thick Hide", :tooltip => "When making a Protection test, on great or extraordinary success attacker is disarmed."},
      :thing_of_terror => { :name => "Thing of Terror", :tooltip => "Unimplemented."},
      :denizen_of_the_dark => { :name => "Denizen of the Darkness", :tooltip => "Unimplemented."},
      :snake_like_speed => { :name => "Snake-like Speed", :tooltip => "On being hit, spend Hate to retroactively increase Parry by attribute level."},
      :strike_fear => { :name => "Strike Fear", :tooltip => "Unimplemented."},
      :craven => { :name => "Craven", :tooltip => "Will attempt to flee if Hate reduced to zero."},
      :bewilder => { :name => "Bewilder", :tooltip => "Unimplemented."},
      :commanding_voice => { :name => "Commanding Voice", :tooltip => "Unimplemented."},
      :great_leap => { :name => "Great Leap", :tooltip => "Unimplemented."},
      :mirkwood_dweller => { :name => "Mirkwood Dweller", :tooltip => "Unimplemented."},
      :dreadful_spells => { :name => "Dreadful Spells", :tooltip => "Unimplemented."},
      :dwarf_hatred => { :name => "Hatred (Dwarves)", :tooltip => "All rolls considered 'favoured' against Dwarves."},
      :hobbit_hatred => { :name => "Hatred (Hobbits)", :tooltip => "All rolls considered 'favoured' against Hobbits."},
      :hatred => { :name => "Hatred", :tooltip => "Unimplemented."},

#      :symbol => { :name => "", :tooltip => "Unimplemented."},
    }
  end
  
  def armor_favoured?
    @armor_favoured
  end
  
  def self.fromParams params
    monsterClass = (Object.const_get(params[:monsterclass]));
    m = monsterClass.createType params[:monstertype]
    m.sauron_rule = params[:sauron_rule]
    m.favoured_skills_rule = params[:favoured_skills] == "on"
    
    m
  end
  
  def confirmAbilities params
    symbols = params.keys.collect{|k| k.to_sym }
    @abilities.keys.each do | a |
      if !(symbols.include? a)
        @abilities.delete a
      end
    end
  end
  
  def rollWeaponSkill
    self.roll self.weaponSkill, ((self.weaponFavoured? && @favoured_skills_rule) ? self.attribute_level : 0)
  end
  
  def weaponDamage
    damage = super
    if( (@abilities.include? :horrible_strength) && @current_hate > 0 && (rand() < 0.5) )
      damage += @attribute_level
        FightRecord.addEvent( self, :hate, {:type => :horrible_strength} )
      self.spendHate
    end
    damage
  end
  
  def takeDamage( opponent, amount )
    if( ( @abilities.include? :hideous_toughness ) && amount >= @attribute_level && @current_hate > 0 )
      amount -= @attribute_level
      FightRecord.addEvent( self, :hate, {:type => :hideous_toughness} )
      self.spendHate
    end
    
    if HouseRule.include? :angelalexs_rule_monsters
      super opponent, [amount - self.protection[0], 0].max
      return
    end
    
    super( opponent, amount ) # have to manually send params because damage may have changed? Not sure.
  end
  
  def spendHate
    @current_hate -= 1
    if( @current_hate < 1 )
      FightRecord.addEvent( self, :out_of_hate, nil )
    end
  end
  
  def hasAbility? ability
    @abilities.include?(ability) || @optional_abilities.include?(ability)
  end
  
  def attackerRolledSauron
    if @sauron_rule
      self.addCondition :called_shot
    end
  end
  
  def to_hash
    {
      "Attribute Level" => self.attribute_level,
      "Endurance" => self.endurance,
      "Hate" => self.hate,
#      "Unique" => self.unique.to_s,
      "Weapon Skill" => "#{self.weaponSkill}#{(self.weaponFavoured? ? ' (favoured)' : '')}",
      "Weapon" => self.weapon.to_s,
#      "Secondary Weapon" => ( @secondary_weapon ? @secondary_weapon.to_s : "None"),
      "Protection" => self.protection[0].to_s + "d +" + self.protection[1].to_s,
      "Parry" => self.parry,
      "Special Abilities" => @abilities.keys.join(','),
      "Optional Abilities" => (@optional_abilities ? @optional_abilities.keys.join(',') : nil )
    }
  end
  
  def self.monsters
    @@monsters
  end
    
  def self.register subclass
    if !@@monsters 
      @@monsters = Set.new
    end
    @@monsters.add subclass
  end
  
  def initFromType typeSymbol, weapon=nil
    type = self.class.types[typeSymbol.to_sym]
    @name = type[:name]
    @abilities = Hash[type[:abilities].collect{ |k| [k,Monster.abilities[k]]}] # yikes. take array of symbols and build hash
    if( type[:optional_abilities] )
      @optional_abilities = Hash[type[:optional_abilities].collect{ |k| [k,Monster.abilities[k]]}]
    end
    @attribute_level = type[:attribute_level]
    @hate = type[:hate]
    @current_hate = @hate
    @armor_favoured = type[:armor_favoured]
    if type.include? :unique
      @unique = type[:unique]
    end
    @endurance = type[:endurance]
    @current_endurance = @endurance
    self.armor = type[:armor]
    @size = type[:size]
    @parry = type[:parry]
    self.shield = type[:shield]
    self.parseWeapons type[:weapons]
#    weaponKey = weapon ? weapon : type[:weapons].keys[0]; #default to first weapon
#    self.weapon = self.weapons[weaponKey];
#    if( type[:weapons].size > 0 )
#      self.secondary_weapon = type[:weapons].keys[1] # this is a pile of shit...need to refactor
#    end
#    @weapon_skill = type[:weapons][weaponKey]
    self
  end
  
  def parseWeapons array
    @weapons = []
    array.each do | entry |
      weapon = self.class.weapons[entry[:type]]
      if !weapon
        puts "Missing weapon '" + :type.to_s + "' for " + @name
      else
        if( weapon.type == :attribute )
          weapon.damage = @attribute_level
        end
        skill = entry[:skill]
        newentry = { :weapon => weapon, :skill => skill, :favoured => entry[:favoured] }
        @weapons.push newentry
      end
    end
  end
  
  def weapon
    super @current_weapon_index
  end
  
  def weaponSkill
    super @current_weapon_index
  end
  
  def weaponFavoured?
    super @current_weapon_index
  end
  
  def resistPierce opponent
    super
    if( @abilities.keys.include? :thick_hide ) && @dice.tengwars > 0
      opponent.addCondition :disarmed
      FightRecord.addEvent( self, :hate, {:type => :thick_hide} )
      FightRecord.addEvent( self, :disarmed, nil ) # should move this addConditions...
    end
  end
  

  
#  def weapon_skill
#    if @weapons && @weapons.size > 0
#      @weapons[@current_weapon_index][:skill]
#    else
#      super
#    end
#  end
      
  
  def self.createType typeSymbol, weapon=nil
    self.new.initFromType typeSymbol, weapon
  end
  
  def weapon=(newWeapon)
    super
    if( @weapon.type == :attribute )
      @weapon.damage = @attribute_level
    end
    weapon
  end
      
  def armor=(newArmor)
     if (newArmor.kind_of? Fixnum) 
       @armor = Armor.new( @name + " Armor", newArmor, 0 )
     else
       super
     end
     @armor
   end

   def shield=(newArmor)
     if newArmor.kind_of? Fixnum
       @shield = Shield.new( self.class.to_s + " Shield", newArmor, 0)
     else 
       super
     end
     @shield
   end

  
   def protection opponent=nil
     bonus =  + (@armor_favoured ? @attribute_level : 0 )
     if opponent && (opponent.weapon.hasQuality? :splitting) && (opponent.dice.gandalf?)
       [@armor.value-1,bonus]
     else
       [@armor.value, bonus]
     end
   end
      
  
  def self.weapons
    Hash.new
  end
  
  def self.armors
    Hash.new
  end
  
  
  def maxEndurance
    @endurance
  end
  
  def hit_by? opponent
    if( !opponent.dice.gandalf? && @abilities.keys.include?( :snake_like_speed ) && @current_hate > 0 )
      tn = opponent.tnFor self
      d = opponent.dice.total
      if (d > tn) && ((d - tn) < (self.parry opponent)) && (HouseRule.include?(:vengers_rule) ? (opponent.dice.tengwars > 0 || opponent.dice.feat >= opponent.weapon.edge) : true )
        FightRecord.addEvent( self, :hate, {:type => :snake_like_speed })
        self.spendHate 
        return false
      end
    end
    super
  end
  
  def post_hit opponent
    if ( opponent.alive? && @current_weapon_index == 0 && (@abilities.include? :savage_assault) && (@dice.tengwars > 0) )
      @current_weapon_index = ((@weapons.size > 1) ? 1 : 0 )
      FightRecord.addEvent( self, :hate, {:type => :savage_assault} )
      self.attack opponent
    end
    @current_weapon_index = 0      
  end
  
  
  def parry opponent=nil
    if !@parry
      @parry = 0
    end
       
    @parry
  end
  
  def reset
    super
    @current_hate = @hate
  end
  
  def tnFor opponent
    if opponent.kind_of? Hero
      opponent.tn self
    else
      0 # ....not sure when this would happen....
    end
  end
  
  def tn opponent 
    if opponent.kind_of? Hero
      opponent.stance + self.defenses
    else
      9 + self.defenses # not sure when this would happen....
    end
  end
  
  def alive?
    if( @abilities.include? :craven && @current_hate < 1 )
      FightRecord.addEvent( self, :hate, {:type => :craven})
      return false
    else
      return super && (@wounds < ((@abilities.include? :great_size) ? 2 : 1))
    end
  end
  
  
  def weary?
    super || (@current_hate < 1)
  end
  
  def damageBonus
    self.attribute_level
  end
  
  # special ability use
  def bewilder opponent
    opponent.addCondition :bewildered
  end
  
  
end

    
    
