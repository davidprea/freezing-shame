require './opponent'
require 'set'

class Hero < Opponent
    
  attr_accessor :body, :wits, :heart
  attr_accessor :f_body, :f_wits, :f_heart # favoured value bonus (e.g., delta, not total)
  attr_accessor :fatigue, :stance
  attr_accessor :wisdom, :valor
  attr_accessor :feats #generic for Virtues AND Rewards
  attr_accessor :favoured_weapon, :r_favoured_weapon
  
  @@cultures = Set.new
  @@gear = Hash.new
  
  def initialize
    super
    puts "Hero intializing"
    @body = 0
    @wits = 0
    @heart = 0
    @f_heart = 0
    @f_wits = 0
    @f_body = 0
    @fatigue = 0
    @stance = 9
    @wisdom = 0
    @valor = 0
    @feats = Set.new
  end
  
  def self.fromParams params
#    params.keys.each do | key |
#     puts key.to_s + ":" + params[key].to_s
#    end
    heroClass = (Object.const_get(params[:culture]));
    hero = heroClass.new
    background = hero.class.backgrounds[params[:background].to_sym] # need some error checking on this one
    hero.name = "Hero"
    hero.body = background[:body]
    hero.heart = background[:heart]
    hero.wits = background[:wits]
    hero.weapon = params[:weapon].to_sym
    hero.armor = params[:armor].to_sym
    hero.shield = params[:shield].to_sym
    hero.helm = params[:helm].to_sym
    hero.weapon_skill = params[:Weapon_skill].to_i
    hero.stance = params[:stance].to_i
    self.virtues.keys.each do |v|
      if params.keys.include? v.to_s
        hero.addVirtue v
        puts "Virtue found: " + v.to_s
      end
    end
    
    3.times do |i|
      tag = "favoured_attribute_" + (i + 1).to_s
      case params[tag.to_sym]
      when "body"
        hero.f_body = i + 1
      when "wits"
        hero.f_wits = i + 1
      when "heart"
        hero.f_heart = i + 1
      end
    end
    
    hero.armor.addParams params
    hero.shield.addParams params
    hero.weapon.addParams params
    hero.helm.addParams params
    hero
  end
  	
  
  def self.cultureName
    self.to_s
    # implemented by subclasses if different from class name
  end
  
  def self.registerCulture subclass
    @@cultures.add subclass
  end
  
  def self.cultures
    # figure out how to do this algorithmically
    @@cultures.sort{ |a,b| a.to_s <=> b.to_s }
  end
  
  
  
  def self.gear type = nil, reward_symbol = nil
    puts "Type: " + type.to_s + " Symbol: " + reward_symbol.to_s

    if @@gear.size == 0
      puts "Initialize master gear list"
      @@gear[:dagger] = Weapon.new( "Dagger", 3, 12, 12, 0, :one_handed, nil );
      @@gear[:short_sword] = Weapon.new( "Short Sword", 5, 10, 14, 1, :one_handed, nil)
      @@gear[:sword] = Weapon.new("Sword", 5, 10, 16, 2, :one_handed, nil)
      @@gear[:long_sword] = Weapon.new("Long Sword", 5, 10, 16, 3, :versatile, nil)
      @@gear[:spear] = Weapon.new("Spear", 5, 9, 14, 2, :throwable, nil)
      @@gear[:great_spear] = Weapon.new("Great Spear", 9, 9, 16, 4, :two_handed, nil)
      @@gear[:axe] = Weapon.new("Axe", 5, 12, 18, 2, :one_handed, nil)
      @@gear[:great_axe] = Weapon.new("Great Axe", 9, 12, 20, 4, :two_handed, nil)
      @@gear[:long_hafted_axe] = Weapon.new("Long-hafted Axe", 5, 12, 18, 3, :versatile, nil)
      @@gear[:bow] = Weapon.new("Bow", 5, 10, 14, 1, :ranged, nil)
      @@gear[:great_bow] = Weapon.new("Great bow", 7, 10, 16, 3, :ranged, nil)
      @@gear[:no_shield] = Shield.new("None", 0, 0)
      @@gear[:no_helm] = Helm.new("None", 0, 0)
      @@gear[:no_armor] = Armor.new("None", 0, 0)
      @@gear[:leather_shirt] = Armor.new("Leather shirt", 1, 4)
      @@gear[:leather_corslet] = Armor.new("Leather corslet", 2, 8)
      @@gear[:mail_shirt] = Armor.new("Mail shirt", 3, 12)
      @@gear[:coat_of_mail] = Armor.new("Coat of mail", 4, 16)
      @@gear[:mail_hauberk] = Armor.new("Mail hauberk", 5, 20)
      @@gear[:cap] = Helm.new("Cap of iron and leather", 1, 2)
      @@gear[:helm] = Helm.new("Helm", 4, 6)
      @@gear[:buckler] = Shield.new("Buckler", 1, 1)
      @@gear[:shield] = Shield.new("Shield", 2, 2)
      @@gear[:great_shield] = Shield.new("Great shield", 3, 3)
    end
    
    rg = self.rewardGear @@gear
    if reward_symbol != nil && (rg.keys.include? reward_symbol)
      item = rg[reward_symbol]
      if item != nil        
        return { reward_symbol => item }
      end
    end
    
        
    if type != nil && type != "None"
      type = (type.is_a? String) ? Object.const_get(type) : type
      return @@gear.select{ |k,v| v.is_a? type }
    end
    
    @@gear
    # return ((filter == nil) ? result : self.filter( result, filter, Weapon ))
  end
  
  def self.rewardGear gearList=nil
    result = {}
    if !gearList
      gearList = self.gear
    end
   
    data = self.rewardGearData
    data.each do |d|
      if gearList.keys.include? d[:base]
        item = gearList[d[:base]].clone d[:name]
        item.addQuality d[:quality]
        result[item.name2sym] = item
      else
        item = Modifier.new( d[:name], 0 )
        result[d[:quality]] = item
      end
    end
    result
  end
 
  def self.rewardGearData
    [] # implemented by subclasses
  end
   
  

  def hasVirtue? virtue
    @feats.include? virtue
  end
  
  def addVirtue virtue
    @feats.add virtue
  end
  # 
  def self.enduranceBase
    0 # implemented by subclasses
  end
  
  def self.hopeBase
    0 # implemented by subclasses
  end
  
  def totalFatigue
    @fatigue + self.encumbrance
  end
  
  def encumbrance
    @armor.encumbrance + @helm.encumbrance + @shield.encumbrance + @weapon.encumbrance
  end
  
  def maxEndurance
    super + ((self.hasVirtue? :resilience) ? 2 : 0)
  end
  
  def valourCheck? tn=14
    @dice.roll( @valour, self.weary?, 0)
    @dice.test tn
  end
  
  def wisdomCheck tn=14
    @dice.roll( @wisdom, self.weary?, 0)
    @dice.test tn
  end
  
  
  # testing out setter override
  def body=(new_body )
    @body = new_body
    @endurance = self.class.enduranceBase + @body
  end

  def setBody(new_body, favoured_bonus )
    @body = new_body
    @f_body = favoured_bonus
  end

  def setHeart(new_heart, favoured_bonus )
    @heart = new_heart
    @f_heart = favoured_bonus
  end
  
  def setWits(new_wits, favoured_bonus )
    @wits = new_wits
    @f_wits = favoured_bonus
  end

  def self.virtues #modifiers applied to gear
    result = {}
    result[:confidence] = {:name => "Confidence", :implemented => false}
    result[:dour_handed] = {:name => "Dour-handed", :implemented => true}
    result[:expertise] = {:name => "Expertise", :implemented => false}
    result[:fell_handed] = {:name => "Fell-handed", :implemented => true}
    result[:gifted] = {:name => "Gifted", :implemented => false}
    result[:resilience] = {:name => "Resilience", :implemented => true}
    result
  end
  
  def self.rewards #modifiers applied to self
    # problem....some qualities apply only to some armor items...
    # maybe compare qualities handled by item to qualities avaialble to character?
    result = {}
    result[:cunning_make_armor] = {:type => "modifier", :name => "Cunning Make (Armor)", :implemented => true}
    result[:cunning_make_shield] = {:type => "modifier", :name => "Cunning Make (Shield)", :implemented => true}
    result[:cunning_make_helm] = {:type => "modifier", :name => "Cunning Make (Helm)", :implemented => true}
    result[:close_fitting_armor] = {:type => "modifier", :name => "Close Fitting (Armor)", :implemented => true}
    result[:close_fitting_helm] = {:type => "modifier", :name => "Close Fitting (Helm)", :implemented => true}
    result[:reinforced] = { :type => "modifier", :name => "Reinforced (Shield)", :implemented => true}
    result[:grievous] = {:type => "modifier", :name => "Grievous", :implemented => true}
    result[:keen] = {:type => "modifier", :name => "Keen", :implemented => true}
    result[:fell] = {:type => "modifier", :name => "Fell", :implemented => true}
    
    if( self.superclass == Hero )
      rg = self.rewardGear
      rg.keys.each do | key |
        item = rg[key]
        result[key] = { :type => item.class.to_s, :name => item.name, :implemented => true }
      end
    end
    result
  end

    
  
  def self.featList
    [:confidence, :dour_handed, :expertise, :fell_handed, :resilience, :cunning_make, :close_fitting, :reinforced, :grievous, :keen, :fell]
  end
  
  def damageBonus
    # @favoured_weapon ? @body + @f_body : @body
    @body
  end
  
  def weaponDamage
    damage = super
    if (self.hasVirtue? :dour_handed) && (@weapon.type == :ranged)
      damage += 1
    end
    if (self.hasVirtue? :fell_handed) && (@weapon.type != :ranged)
      damage += 1
    end
    damage
  end
  
  
  def reset
    super
  end
  
  def feat symbol
    # look up mask value for this symbol
    maskValue = self.maskValueFor symbol
    # check to see if this virtue or reward has already been added; exit if it has
    if @feats & maskValue > 0
      return
    end
    # apply the virtue or reward (how to get logic from subclasses?)
    self.applyFeat symbol
    # modify mask
    @virtues_rewards |= maskValue
    # now modify character or gear, when appropriate...
  end
  
 
  def self.sample
    h = Hero.new
    h.parry = 3
    h.stance = 9
    h.weapon_skill = 3
    h
  end
  
  def parry
    self.wits + (self.weapon.allows_shield? ? self.shield.value : 0 )
  end
  
  def protection
    [(@armor ? @armor.value : 0), (@helm ? @helm.value : 0)]
  end
  
  
  
  def tn opponent  # this is TN to get hit; opponent argument only there for monsters
    @stance + ((@conditions.include? :bewildered) ? 0 : self.parry)
  end
  
  def alive?
    return super && wounds < 2
  end
  
  
  def weary?
    super || (self.totalFatigue > @endurance)
  end
  
  def attackRoll
    @dice.roll( self.weapon_skill, self.isWeary, 0 )
    return d
  end
end   

