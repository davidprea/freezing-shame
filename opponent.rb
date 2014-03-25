require './dice'
require './gear'
require './weapon'
require './fightrecord'

class Opponent  

  attr_accessor :dice
  attr_accessor :name
  attr_accessor :size # 2 == Hobbit, 3 == Man
  attr_accessor :current_endurance
  #attr_accessor :weapon_name, :weapon_damage, :weapon_edge, :weapon_injury
  attr_accessor :token # used for adding events to FightRecord 

  
  def maxEndurance
    0 # implemented by subclasses
  end
  
  def initialize
    @conditions = Set.new
    @size = 2 # default size.  1 = hobbit or smaller, 2 = man(ish), 3 = larger
  end
  
  def addCondition symbol
    @conditions.add symbol
  end
  
  def removeCondition symbol
    @conditions.delete symbol
  end
  
  def hasCondition? symbol
    @conditions.include? symbol
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
  
  # don't use this
  def weapon=(newWeapon)
    puts "Should not be assigning @weapon"
  end
  
  def addWeapon weapon, skill, favoured=false
    if !@weapons
      @weapons = Array.new
    end
        
    if weapon.class == Weapon
      @weapons.push( :weapon => weapon, :skill => skill, :favoured => favoured )
      return
    end      
    
    if weapon.class == Symbol
      self.addWeapon( self.class.gearForSymbol(weapon,nil), skill, favoured )
      return
    end
  end
  
  def endurance
    @endurance
  end
  
  def weapon id=0
    @weapons[id][:weapon]
  end
  
  def weaponSkill weapon=0
    if( weapon.is_a? Integer )
      return @weapons[weapon][:skill]
    elsif( weapon.is_a? Weapon )
      return @weapons.select{|x| x[:weapon] == weapon}.first[:skill]
    elsif( weapon.is_a? Symbol )
      return @weapons.select{|x| x[:weapon] == self.class.gearForSymbol(weapon)}.first[:skill]
    else
      puts "#{self.class} passed a #{weapon.class} to method weaponSkill"
      return nil
    end
  end
  
  #move armor, shield, helm into "@gear"
  
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
  
  def encumbrance
    0 # zero for monsters, overridden by heroes
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
  
  
  def defenses opponent=nil
    if self.hasCondition? :fumble
      self.removeCondition :fumble
      return 0
    end
    
    total = self.parry(opponent) + self.shieldValue + self.otherDefensiveBonus(opponent)
    
    if HouseRule.include?(:avenues_rule) 
      total += [self.armor.value - 2, 0].max
    elsif HouseRule.include?(:avenues_rule_modified)
      total += [self.armor.value - 3, 0].max
    end
    
    total
  end
  
  def otherDefensiveBonus opponent=nil
    0 # including this just in case
  end
  
  def parry opponent=nil
    0 # overridden by subclasses
  end
  
  def shieldValue
    ((self.shield && self.weapon.allows_shield?) ? self.shield.value : 0 )
  end
  
  
  
  def wound
    @wounds += 1
    if @token
      FightRecord.addEvent( self, :wound, { :dice => @dice.clone, :wounds => @wounds} )
    end
  end
    
  def reset
    @wounds = 0
    @is_shield_broken = false
    @current_endurance = self.maxEndurance
    @conditions = Set.new
    self.armor.reset
    self.shield.reset
    self.helm.reset
  end
  
  def alive?
    @current_endurance > 0
  end

  def weary?
    (self.hasCondition? :weary)
  end
  
  def damageBonus
    0 #overridden by subclass
  end
  
  def tn opponent
    0 #overridden by subclasss
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
  
  #handle this when initializing?
  def weaponDamage 
    damage = self.weapon.damage
    if( self.weapon.type == :versatile && @shield.value == 0 )
      damage += 2
    end
    damage
  end
  
  #handle this when initializing?
  def weaponInjury
    injury = self.weapon.injury
    if( self.weapon.type == :versatile && @shield.value == 0)
      injury += 2
    end
    injury
  end
  
  def extraSuccesses
    @dice.tengwars
  end
  
  def computeDamage
    damage = self.weaponDamage
    self.extraSuccesses.times do
      damage += self.damageBonus
    end
    damage
  end
    
  
  def getHitBy opponent
    damage = opponent.computeDamage
    self.takeDamage opponent, damage
  end
  
  def post_hit opponent
    # don't do anything extra, override in subclasses
  end
  
  def takeDamage opponent, amount
    @current_endurance -= amount
    FightRecord.addEvent( self, :damage, {:amount => amount, :health_left => @current_endurance } )
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
  
  def piercingBlow?
    self.dice.feat >= self.weapon.edge
  end
  
  
    
  def hit opponent
    if( self.hasCondition? :called_shot )
      self.removeCondition( :called_shot )
      if @dice.tengwars > 0
        opponent.resistPierce self 
      else
        return #abort completely if no tengwars
      end
      #now call it again with @called_shot off to resolve normally and exit
      return self.hit opponent
    end
    
    opponent.getHitBy self          
    if self.piercingBlow?
      opponent.resistPierce self 
    end
    
    self.post_hit opponent  # just in case there are post hit actions   
  end
  
  def resistPierce opponent
    tn = opponent.weaponInjury
    mod = (opponent.dice.gandalf? && opponent.weapon.hasQuality?( :dalish ) ? -1 : 0 )
    prot = self.protection opponent
    self.dice.roll( prot[0], self.weary?, mod )
    self.dice.bonus = prot[1]
    FightRecord.addEvent( self, :pierce, nil )
    FightRecord.addEvent( self, :armor_check, {:dice => @dice.clone, :tn => tn } )
    if( HouseRule.include?(:richs_rule) && self.dice.sauron? )
      self.armor.takeDamage
      FightRecord.addEvent(self, :armor_damage, {:armor_left => self.armor.value} )
    end
    self.checkForWound tn
  end
  
  
  
  # if opponent is still alive will attack back
  def attack( opponent)
    
    # skip turn if disarmed
    [:disarmed, :knockback].each do | condition |
      if self.hasCondition? condition
        self.removeCondition condition
        FightRecord.addEvent( self, :skip, nil )
        return
      end
    end
    
    if( opponent.is_a? Array )
      self.attack( opponent.last )
      if( !opponent.last.alive? )
        opponent.pop
      end
      return
    end
    
    self.roll( self.weaponSkill )
        
    tn = self.tnFor opponent
    
    FightRecord.addEvent( self, :attack, {:dice => @dice.clone, :tn => tn, :called => self.hasCondition?(:called_shot) } )
    
    if( self.hit?(opponent) && opponent.hit_by?(self)) # give opponent one last chance to avoid...
      self.hit opponent
    elsif self.hasCondition? :called_shot
      if self.dice.sauron?
        self.addCondition :fumble
        FightRecord.addEvent( self, :fumble, nil )
      end
      self.removeCondition :called_shot
    end

    if( @dice.sauron? )
      opponent.attackerRolledSauron
    end
    
    if !opponent.alive?
      FightRecord.addEvent( opponent, :dies, nil )
    end 
    
  end
  
  
  
end


