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
      "Special Abilities" => @abilities.join(',')
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
    @abilities = type[:abilities].dup  #.collect{|x| x.to_sym} 
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
  
   def protection
     [@armor, 0]
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
    if( @abilities.include? :snake_like_speed )
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

    
    
