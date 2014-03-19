require './dice'
require './gear'
require './weapon'
require './fightrecord'

class Opponent  

  attr_accessor :dice
  attr_accessor :name, :endurance, :weapon_skill, :wounds
  attr_accessor :size # 2 == Hobbit, 3 == Man
  attr_accessor :armor, :shield, :helm
  attr_accessor :current_endurance
  attr_accessor :weapon, :weapon_skill
  attr_accessor :rweapon, :r_weapon_skill # ranged.  NYI
  #attr_accessor :weapon_name, :weapon_damage, :weapon_edge, :weapon_injury
  attr_accessor :conditions # catch-all for temporary combat modifiers
  attr_accessor :called_shot # will next attack be called shot?
  attr_accessor :token # used for adding events to FightRecord 

  
  def maxEndurance
    0 # implemented by subclasses
  end
  
  def initialize
    @conditions = Set.new
    @called_shot = false
    @size = 3 # default size
  end
  
  def addCondition symbol
    @conditions.add symbol
  end
  
  def removeCondition symbol
    #NYI
  end
  
  def weapons
    return self.class.weapons
  end
  
  def self.weapons filter = nil
    return Hash.new
  end
  
  def attackerRolledSauron
    #god this is an ugly way to do this....
  end
  
  def self.gearForSymbol aSymbol, type
    list = self.gear type, nil
    if list.include? aSymbol 
      return list[aSymbol].clone
    elsif (rg = self.rewardGear).keys.include? aSymbol
      return rg[aSymbol].clone
    else
      return list[:none] # I think this is going to break for weapon
    end
  end
  
  def weapon=(newWeapon)
    if newWeapon.class == Weapon
      @weapon = newWeapon
    elsif newWeapon.class == Symbol
      @weapon = self.class.gearForSymbol newWeapon, Weapon
    else
      puts "Error setting weapon: sent class " + newWeapon.class.to_s
    end
    @weapon
  end
  
  
  def armor=(newArmor)
    if newArmor.kind_of? Armor
      @armor = newArmor
    elsif newArmor.kind_of? Symbol
      @armor = self.class.gearForSymbol newArmor, Armor
    else
      puts "Error setting armor: sent class " + newArmor.class.to_s
    end
    @armor
  end

  def shield=(newArmor)
    if newArmor.kind_of? Shield
      @shield = newArmor
    elsif newArmor.kind_of? Symbol
      @shield = self.class.gearForSymbol newArmor, Shield
    else
      puts "Error setting shield: sent class " + newArmor.class.to_s
    end
    @shield
  end
  
  def helm=(newArmor)
    if newArmor.kind_of? Helm
      @helm = newArmor
    elsif newArmor.kind_of? Symbol
      @helm = self.class.gearForSymbol newArmor, Helm
    else
      puts "Error setting helm: sent class " + newArmor.class.to_s
    end
    @heml
  end
  
  def self.rewardGear gearList=nil
    {} # implemented by subclasses
  end
  
      
  def self.rewards #modifiers applied to gear
    {} #implemented by sub-classes
  end
  
  def self.virtues #modifiers applied to self
    {} #implemented by sub-classes
  end
  
  def self.gear filter = nil, type = nil
    {}
  end

#  def self.shields filter = nil
#    self.gear.keep_if {|k,v| v.class == Shield }
#  end
#
#  def self.helms filter = nil
#    self.gear.keep_if {|k,v| v.class == Helm }
#  end
#  
#  def self.armors filter = nil
#    self.gear.keep_if {|k,v| v.class == Armor }
#  end


  
  def armor
    if @armor == nil
      @armor = Armor.new("Nekked", 0, 0)
    end
    @armor
  end

  def shield
    if @shield == nil
      @shield = Shield.new("No Shield", 0, 0)
    end
    @shield
  end

  def helm
    if @helm == nil
      @helm = Helm.new("No Helm", 0, 0)
    end
    @helm
  end
  
  def parry opponent=nil
    0 # implemented by subclasses
  end
  
  def wound
    @wounds += 1
    if @token
      FightRecord.addEvent( @token, self.name, :wound, @dice, self.wounds )
    end
  end
    
  def reset
    @wounds = 0
    @is_shield_broken = false
    @current_endurance = self.maxEndurance
    @conditions = Set.new
  end
  
  def alive?
    @current_endurance > 0
  end

  def weary?
    (@conditions.include? :weary)
  end
  
  def weaponSkill
    self.weapon_skill
  end
  
  def damageBonus
    0 #overridden by subclass
  end
  
  def tn opponent
    0 #overridden by subclasss
  end
  
  def rollProtectionAgainst opponent
    tn = opponent.weaponInjury
    mod = (opponent.dice.gandalf? && opponent.weapon.hasQuality?( :dalish ) ? -1 : 0 )
    prot = self.protection opponent
    self.dice.roll( prot[0], self.weary?, mod )
    self.dice.bonus = prot[1]
    FightRecord.addEvent( @token, self.name, :pierce, nil, nil )
    FightRecord.addEvent( @token, self.name, :armor_check, @dice, tn )
    self.checkForWound tn
  end
  
  def checkForWound tn
    test = @dice.test tn
    if !test
      self.wound
    end
  end
    
  
  def protection opponent=nil
    [(@armor ? @armor.value : 0), 0]
  end
  
  def dice
    if @dice == nil
      @dice = Dice.new
    end
    @dice
  end
  
  def roll diceCount
    (self.dice).roll( diceCount, self.weary?, 0 )
  end
  
  #special events
  def smashShield
  end
  
  def disarm
  end
  
  def intimidate
  end
  
  def weaponDamage 
    damage = self.weapon.damage
    if( self.weapon.type == :versatile && @shield.value == 0 )
      damage += 2
    end
    damage
  end
  
  def weaponInjury
    injury = self.weapon.injury
    if( self.weapon.type == :versatile && @shield.value == 0)
      injury += 2
    end
    injury
  end
  
  def getHitBy opponent
    damage = opponent.weaponDamage
    opponent.dice.tengwars.times do
      damage += opponent.damageBonus
    end
    self.takeDamage opponent, damage
  end
  
  def post_hit opponent
    # don't do anything extra, override in subclasses
  end
  
  def takeDamage opponent, amount
    @current_endurance -= amount
    FightRecord.addEvent( @token, self.name, :damage, nil, amount )
  end
    
  
  def rally

  end
  
  def tnFor opponent
    0 # implemented by subclasses
  end
  
  def hit? opponent
    @dice.test self.tnFor(opponent)
  end
  
  
  def hit_by? opponent
    true # potentially overriden by subclasses
  end
    
  def hit opponent
    if( @called_shot )
      FightRecord.addEvent( @token, self.name, :called_shot, nil, nil )
      if @dice.tengwars > 0
        opponent.getHitBy self 
        opponent.wound 
      end
      @called_shot = false
    else
      opponent.getHitBy self      
    
      if (self.weapon.hasQuality?(:kings_blade) && (self.dice.tengwars > 0))
        opponent.wound 
      elsif @dice.feat >= self.weapon.edge
        opponent.rollProtectionAgainst self 
      end
    end
    self.post_hit opponent  # just in case there are post hit actions   
  end
  
  # if opponent is still alive will attack back
  def attack( opponent)
    
    # skip turn if disarmed
    if @conditions.include? :disarmed
      @conditions.delete :disarmed
      FightRecord.addEvent( @token, self.name, :skip, nil, nil )
      return
    end
    
    if( opponent.is_a? Array )
      self.attack( opponent.last )
      if( !opponent.last.alive? )
        opponent.pop
      end
      return
    end
    
    self.roll( self.weapon_skill )
    
    if( @dice.sauron? )
      opponent.attackerRolledSauron
    end
    
    tn = self.tnFor opponent
    
    FightRecord.addEvent( @token, self.name, :attack, @dice.clone, tn )
    
    if( self.hit?(opponent) && opponent.hit_by?(self)) # give opponent one last chance to avoid...
      self.hit opponent
    end
    
    if !opponent.alive?
      FightRecord.addEvent( @token, opponent.name, :dies, nil )
    end 
  end
  
  #deprecated  
  def takeTurn opponent, nest=0 
    self.attack( (opponent.is_a? Array) ? opponent.last : opponent )
    
    if( opponent.alive? )
      opponent.takeTurn( self, nest+1 )
    else
      FightRecord.addEvent( @token, opponent.name, :dies, nil )
    end
  end
end


