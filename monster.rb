#class Weapon
#  String  name
#  Number  damage
#  Number  edge
#  Number  injury
#end

require './opponent'

class Monster < Opponent  
  
  @@monsters = nil
  
  attr_accessor :attribute_level, :parry, :hate, :abilities
  attr_accessor :max_hate, :max_endurance
  attr_accessor :sauron_rule
    
  def initialize
    super
    puts "Monster initializing"
    @parry = 0
    @attribute_level = 1
    @abilities = []
    @sauron_rule = false
    @hate = 1
    @current_weapon_index = 0
    @special_abilities = 0 #bit mask
  end
  
  def self.abilities
    {
      :horrible_strength => { :name => "Horrible Strength", :tooltip => "Spend hate to increase damage by attribute-level. (50% chance per hit.)" },
      :hideous_toughness => { :name => "Hideous Toughness", :tooltip => "Spend hate to reduce damage by attribute-level"},
      :great_size => { :name => "Great Size", :tooltip => "Requires two wounds, or one wound and zero endurance, to kill."},
      :hate_sunlight => { :name => "Hate Sunlight", :tooltip => "Unimplemented."},
      :savage_assault => { :name => "Savage Assault", :tooltip => "On great or extraordinary success, roll second attack with alternate weapon."},
      :seize_victim => { :name => "Sieze Victim", :tooltip => "Unimplemented."},
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
      :hatred => { :name => "Hatred", :tooltip => "Unimplemented."}

#      :symbol => { :name => "", :tooltip => "Unimplemented."},
    }
  end
  
  def self.fromParams params
    monsterClass = (Object.const_get(params[:monsterclass]));
    m = monsterClass.createType params[:monstertype]
    m.sauron_rule = params[:sauron_rule]
    m
  end
  
  def confirmAbilities params
    symbols = params.keys.collect{|k| k.to_sym }
    @abilities.to_a.each do | a |
      if !(symbols.include? a)
        @abilities.delete a
        puts "Ability removed: " + a.to_s
      end
    end
  end
  
  def weaponDamage
    damage = super
    if( (@abilities.include? :horrible_strength) && @hate > 0 && (rand() < 0.5) )
      damage += @attribute_level
        FightRecord.addEvent( @token, self.name, :hate, nil, :horrible_strength.to_s )
      self.spendHate
    end
    damage
  end
  
  def takeDamage( opponent, amount )
    if( ( @abilities.include? :hideous_toughness ) && amount >= @attribute_level && @hate > 0 )
      amount -= @attribute_level
      FightRecord.addEvent( @token, self.name, :hate, nil, :hideous_toughness.to_s )
      self.spendHate
    end
    super( opponent, amount ) # have to manually send params because damage may have changed? Not sure.
  end
  
  def spendHate
    @hate = @hate - 1
    if( @hate < 1 )
      FightRecord.addEvent( @token, self.name, :out_of_hate, nil, nil )
    end
  end
  
  
  def attackerRolledSauron
    if @sauron_rule
      @called_shot = true
    end
  end
  
  def to_hash
    {
      "Attribute Level" => self.attribute_level,
      "Endurance" => self.maxEndurance,
      "Hate" => self.max_hate,
      "Weapon Skill" => self.weapon_skill,
      "Weapon" => self.weapon.to_s,
#      "Secondary Weapon" => ( @secondary_weapon ? @secondary_weapon.to_s : "None"),
      "Protection" => self.protection[0].to_s + "d +" + self.protection[1].to_s,
      "Parry" => self.parry,
      "Special Abilities" => @abilities.keys.join(',')
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
    puts typeSymbol
    type = self.class.types[typeSymbol.to_sym]
    @name = type[:name]
    @abilities = Hash[type[:abilities].collect{ |k| [k,Monster.abilities[k]]}] # yikes. take array of symbols and build hash
    @attribute_level = type[:attribute_level]
    @max_hate = type[:hate]
    @max_endurance = type[:endurance]
    @armor = type[:armor]
    @size = type[:size]
    @parry = type[:parry]
    @shield = type[:shield]
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
      weapon = self.weapons[entry[:type]]
      if !weapon
        puts "Missing weapon '" + :type.to_s + "' for " + @name
      else
        if( weapon.type == :attribute )
          weapon.damage = @attribute_level
        end
        skill = entry[:skill]
        newentry = { :weapon => weapon, :skill => skill}
        @weapons.push newentry
      end
    end
  end
  
  def weapon
    if @weapons && @weapons.size > 0
      @weapons[@current_weapon_index][:weapon]
    else
      super
    end
  end
  
  def rollProtectionAgainst opponent
    super
    if( @abilities.keys.include? :thick_hide ) && @dice.tengwars > 0
      opponent.conditions.add :disarmed
      FightRecord.addEvent( @token, self.name, :hate, nil, :thick_hide )
      FightRecord.addEvent( @token, opponent.name, :disarmed, nil, nil )
    end
  end
  
  
  def weapon_skill
    if @weapons && @weapons.size > 0
      @weapons[@current_weapon_index][:skill]
    else
      super
    end
  end
      
  
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


   def armor
     if @armor == nil
       @armor = 0
     end
     @armor
   end

   def shield
     if @shield == nil
       @shield = 0
     end
     @shield
   end
  
   def protection opponent=nil
     if opponent && (opponent.weapon.qualities.include? :splitting) && (opponent.dice.gandalf?)
       [@armor-1,0]
     else
       [@armor, 0]
     end
   end
      
  
  def self.weapons
    Hash.new
  end
  
  def self.armors
    Hash.new
  end
  
  
  def maxEndurance
    @max_endurance
  end
  
  def hit_by? opponent, dice
    if( @abilities.keys.include? :snake_like_speed )
      tn = opponent.tnFor self
      d = dice.total
      if (d > tn) && ((d - tn) < (self.parry opponent))
        FightRecord.addEvent( @token, @name, :hate, nil, :snake_like_speed )
        self.spendHate 
        return false
      end
    end
    super
  end
  
  def post_hit opponent
    if ( opponent.alive? && @current_weapon_index == 0 && (@abilities.include? :savage_assault) && (@dice.tengwars > 0) )
      @current_weapon_index = ((@weapons.size > 1) ? 1 : 0 )
      FightRecord.addEvent( @token, @name, :hate, nil, :savage_assault )
      self.attack opponent
    end
    @current_weapon_index = 0      
  end
  
  
  def parry opponent=nil
    @parry + ((@shield && self.weapon.allows_shield?) ? @shield : 0)
  end
  
  def reset
    super
    @hate = @max_hate
  end
  
  def tnFor opponent
    if opponent.kind_of? Hero
      opponent.stance + (opponent.parry self)
    else
      0 # ....not sure when this would happen....
    end
  end
  
  def tn opponent 
    if opponent.kind_of? Hero
      opponent.stance + self.parry
    else
      9 + self.parry # not sure when this would happen....
    end
  end
  
  def alive?
    if( @abilities.include? :craven && @hate < 1 )
      FightRecord.addEvent( @token, :hate, :flees, nil, :craven)
      return false
    else
      return super && (wounds < ((@abilities.include? :great_size) ? 2 : 1))
    end
  end
  
  
  def weary?
    super || (@hate < 1)
  end
  
  def damageBonus
    self.attribute_level
  end
  
  # special ability use
  def bewilder opponent
    opponent.conditions.add :bewildered
  end
  
  
end

    
    
