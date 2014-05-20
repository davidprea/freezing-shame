require './opponent'
require 'set'
require './houserule'

class Hero < Opponent
    
  attr_accessor :body, :wits, :heart
  attr_accessor :f_body, :f_wits, :f_heart # favoured value bonus (e.g., delta, not total)
  attr_accessor :fatigue, :stance
  attr_accessor :wisdom, :valor
  attr_accessor :hope, :current_hope
  attr_accessor :cultural_blessing_enabled
  attr_accessor :feats #generic for Virtues AND Rewards
  attr_accessor :weapon_favoured, :r_weapon_favoured # booleans
  attr_accessor :armor_skill
  
  @@cultures = Set.new
  @@gear = Hash.new
  
  def initialize
    super
    @body = 0
    @wits = 0
    @heart = 0
    @hope = 0
    @base_fatigue = 0
    @knockback_rule = false
    @bite_kneecaps = false
    @cultural_blessing_enabled = true
    @f_heart = 0
    @f_wits = 0
    @f_body = 0
    @stance = 9
    @wisdom = 0
    @valor = 0
    @feats = Set.new
  end
  
  def self.culturalBlessing
    {
      :name => "No culture chosen.", 
      :tooltip => "Unimplemented blessings will be flagged with: ",
      :implemented => false
    } # implemented_by_subclasses
  end
  

  
  
  
  def self.fromParams params
#    params.keys.each do | key |
#      puts key.to_s + ":" + params[key].to_s
#    end
    heroClass = (Object.const_get(params[:culture]));
    hero = heroClass.new
    
    hero.fromParams params
  end
  
  def fromParams params
    @name = "Hero"
    background = self.class.backgrounds[params[:background].to_sym] # need some error checking on this one
    @body = background[:body]
    @heart = background[:heart]
    @wits = background[:wits]
    @knockback_rule = params.keys.include? "knockback_rule"
    @base_fatigue = params[:extra_fatigue].to_i
    @bite_kneecaps = params.keys.include? "bite_kneecaps"
    @cultural_blessing_enabled = params[:cultural_blessing] == "on"
    @hope = params[:hope].to_i
    self.armor = params[:armor].to_sym
    self.shield = params[:shield].to_sym
    self.helm = params[:helm].to_sym
    @armor_skill = params[:armor_skill].to_i

    # weapons(s?)
    weapon_favoured = (params[:weapon_favoured] == "on")
    weapon_skill = params[:weapon_skill].to_i
    weapon = params[:weapon].to_sym
    self.addWeapon( weapon, weapon_skill, weapon_favoured )
    
    @stance = params[:stance].to_i
    
    self.class.virtues.keys.each do |v|
      if params.keys.include? v.to_s
        self.addVirtue v
      end
    end
    
    3.times do |i|
      tag = "favoured_attribute_" + (i + 1).to_s
      case params[tag.to_sym]
      when "body"
        @f_body = i + 1
      when "wits"
        @f_wits = i + 1
      when "heart"
        @f_heart = i + 1
      end
    end
    
    self.armor.addParams params
    self.shield.addParams params
    self.weapon.addParams params
    self.helm.addParams params
    self
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
  
  def to_hash
    { 
      "Body" => "#{body}(#{self.f_body})",
      "Heart" => "#{heart}(#{self.f_heart})",
      "Wits" => "#{wits}(#{self.f_wits})",
      "Parry" => self.parry, 
      "Protection" => (self.protection[0].to_s + "d + " + self.protection[1].to_s), 
      "Weapon" => self.weapon.to_s, 
      "Endurance" => self.endurance, 
      "Fatigue" => self.fatigue,
      "Virtues" => "(" + @feats.to_a.join(", ") + ")" 
    }
  end
  
  def encumbrance
    if !@encumbrance
      self.calcEncumbrance
    end
    @encumbrance
  end
  
  def calcEncumbrance
    @encumbrance = @base_fatigue + self.armor.encumbrance + self.helm.encumbrance + self.shield.encumbrance + self.weapon.encumbrance
    @encumbrance
  end
  
  
  
  def self.gear gClass = nil, reward_symbol = nil

    if @@gear.size == 0
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
      @@gear[:cap] = Helm.new("Cap", 1, 2)
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
    
        
    if gClass != nil && gClass != "None"
      gClass = (gClass.class == String) ? Object.const_get(gClass) : gClass
      return @@gear.select{ |k,v| v.class == gClass }
    end
    
    @@gear
    # return ((filter == nil) ? result : self.filter( result, filter, Weapon ))
  end

  def self.backgrounds
    Hash.new
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
  
  def maxEndurance
    self.class.enduranceBase + @body
  end
  
  def self.enduranceBase
    0 # implemented by subclasses
  end
  
  def enduranceBase
    return self.class.enduranceBase
  end
  
  def self.hopeBase
    0 # implemented by subclasses
  end
  
  def fatigue
    self.encumbrance - ((HouseRule.include? :belegs_rule) ? @body : 0)
  end
  
  def takeDamage opponent, amount
    if HouseRule.include? :angelalexs_rule
      amount = [amount - self.protection[0], 0].max;
      super opponent, [amount - self.protection[0], 0].max
    end
    
    if @knockback_rule && opponent.dice.tengwars > 0
      self.addCondition :knockback
      FightRecord.addEvent( self, :knockback, nil )
      amount = amount /2
    end
    
    if self.protection[0] > 0 && HouseRule.include?(:evenings_rule)
      if opponent.dice.feat < opponent.weapon.edge
        self.rollProtection opponent, 0
        if self.dice.tengwars > 0
          absorb = self.dice.tengwars + ( self.protection[0] > 2 ? 1 : 0 )
          FightRecord.addEvent( self, :absorb, { :absorbed => absorb })
          amount -= absorb
        elsif dice.sauron?
          FightRecord.addEvent( self, :knockback, nil )
          self.addCondition :knockback
        end
      end 
    end
    
    super opponent, amount
  end
  
  def getHitBy opponent
    super
    if self.weary? && @bite_kneecaps
      @stance = 6
    end
  end
  

  
  def calculateEncumbrance
    super
    if( HouseRule.include? :belegs_rule )
      @encumbranse = [ 0, @encumbrance - self.body].max
    end
    @encumbrance
  end
  
  def maxEndurance
    self.enduranceBase + @heart + ((self.hasVirtue? :resilience) ? 2 : 0)
  end
  
  def valourCheck? tn=14
    self.roll( @valour )
    @dice.test tn
  end
  
  def wisdomCheck tn=14
    self.roll( @wisdom )
    @dice.test tn
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
  
  def f_body
    @f_body + (self.hasVirtue?(:gifted_body) ? 1 : 0 )
  end
  
  def f_heart
    @f_heart + (self.hasVirtue?(:gifted_heart) ? 1 : 0 )
  end
  
  def f_wits
    @f_wits + (self.hasVirtue?(:gifted_wits) ? 1 : 0 )
  end
  
  def favoured_body
    @body + self.f_body
  end
  
  def favoured_heart
    @heart + self.f_heart
  end
  
  def favoured_wits
    @wits + self.f_wits
  end
  

  def self.virtues 
    result = {}
    result[:confidence] = {:name => "Confidence", :implemented => false}
    result[:dour_handed] = {:name => "Dour-handed", :tooltip => "Increase ranged damage by 1", :implemented => true}
    result[:expertise] = {:name => "Expertise", :implemented => false}
    result[:fell_handed] = {:name => "Fell-handed", :tooltip => "Increase close combat damage by 1", :implemented => true}
    result[:gifted_body] = {:name => "Gifted (Body)", :tooltip => "Raise Favoured Body score by 1", :implemented => true}
    result[:gifted_heart] = {:name => "Gifted (Heart)", :tooltip => "Raise Favoured Heart score by 1", :implemented => true}
    result[:gifted_wits] = {:name => "Gifted (Wits)", :tooltip => "Raise Favoured Wits score by 1", :implemented => true}
    result[:resilience] = {:name => "Resilience", :tooltip => "Increase endurance by 2", :implemented => true}
    result[:thwarting] = {:name => "Thwarting", :tooltip => "Increase Parry by 1 (unofficial).", :implemented => true}
    result
  end
  
  def usesOfHope
    {
      :any_wound => {
        :name => "Avoid Wound",
        :tooltip => "Spend Hope on any failed Protection Wound"
      },
      :second_wound => {
        :name => "Avoid 2nd Wound",
        :tooltip => "Spend Hope to avoid a second Wound" 
      },
      :great_success => {
        :name => "Great Attack",
        :tooltip => "Turn a miss into a hit on a Great Success"
      },
      :extra_success => {
        :name => "Extraordinary Attack",
        :tooltip => "Turn a miss into a hit on an Extraordinary Success"
      },
      :pierce => {
        :name => "Piercing Attack",
        :tooltip => "Turn a miss into a hit on a Pierce"
      }
    }
  end
  
  def self.rewards #modifiers applied to self
    # problem....some qualities apply only to some armor items...
    # maybe compare qualities handled by item to qualities avaialble to character?
    result = {}
    result[:cunning_make_armor] = {:type => "modifier", :name => "Cunning Make (Armor)", :tooltip => "Reduce armor encumbrance by 2.", :implemented => true}
    result[:cunning_make_shield] = {:type => "modifier", :name => "Cunning Make (Shield)", :tooltip => "Reduce shield encumbrance by 2.", :implemented => true}
    result[:cunning_make_helm] = {:type => "modifier", :name => "Cunning Make (Helm)", :tooltip => "Reduce helm encumbrance by 2.", :implemented => true}
    result[:close_fitting_armor] = {:type => "modifier", :name => "Close Fitting (Armor)", :tooltip => "Increase armor protection by 1D.", :implemented => true}
    result[:close_fitting_helm] = {:type => "modifier", :name => "Close Fitting (Helm)", :tooltip => "Increase helm protection by +1", :implemented => true}
    result[:reinforced] = { :type => "modifier", :name => "Reinforced", :tooltip => "Increase Parry by one; immune to Smash.", :implemented => true}
    result[:grievous] = {:type => "modifier", :name => "Grievous", :tooltip => "Increase weapon damage by 2.", :implemented => true}
    result[:keen] = {:type => "modifier", :name => "Keen", :tooltip => "Improve weapon edge rating by 1.", :implemented => true}
    result[:fell] = {:type => "modifier", :name => "Fell", :tooltip => "Increase weapon injury rating by 2.", :implemented => true}
    
    if( self.superclass == Hero )
      rgd = self.rewardGearData
      rg = self.rewardGear
      # ok this is ugly
      rg.keys.each do | key |
        item = rg[key]
        name = item.name
        data = rgd.select{|x| x[:name] == name }.first
        if data
          result[key] = {:type => item.class.to_s, :name => name, :tooltip => data[:tooltip], :implemented => true }
        else
          puts key.to_s + " not found."
        end
#        item = rg[key]
#        result[key] = { :type => item.class.to_s, :name => item.name, :implemented => true }
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
    if (self.hasVirtue? :dour_handed) && (self.weapon.type == :ranged)
      damage += 1
    end
    if (self.hasVirtue? :fell_handed) && (self.weapon.type != :ranged)
      damage += 1
    end
    damage
  end
  
  # only call this when computing damage....?
  def extraSuccesses
    if HouseRule.include? :woodclaws_rule
      return [@dice.allTengwars, (15 - @stance) / 3].min
    end
    super
  end
  
  def reset
    super
    @current_hope = @hope
  end
  
  #wtf is this method for?
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
  
  def spendHope type
    @current_hope -= 1
    FightRecord.addEvent( self, :hope, { :type => type, :hope_left => @current_hope })
  end
    
  def defenses opponent=nil
    if self.hasCondition? :bewildered
      return 0
    elsif self.hasCondition? :seized
      return (super / 2.0).ceil
    else
      return super
    end
  end
    
  def parry opponent=nil
    @wits + (@feats.include?(:thwarting) ? 1 : 0)
  end
  
  
  def protection opponent=nil
    [(@armor ? @armor.value : 0), (@helm ? @helm.value : 0)]
  end
  
  def checkForWound tn
    test = @dice.test tn
    if !test && @current_hope > 0 && @wounds > 0
      if (tn - @dice.total) <= @body
        self.spendHope :protection
        return 
      end
    end
    #otherwise just default to regular behavior
    super
  end 
  
  
  def hit? opponent
    if !super && (@current_hope > 0)
      attribute_bonus = @body + ( @favoured_weapon ? self.f_body : 0 )
      if !@dice.sauron? && (self.tnFor(opponent) - @dice.total <= attribute_bonus && @dice.tengwars > 0 )
        self.spendHope :tengwar
        @dice.bonus += attribute_bonus # modify the dice and return super
      elsif !@dice.sauron? && (self.tnFor(opponent) - @dice.total <= attribute_bonus) && ( @dice.feat >= self.weapon.edge )
        self.spendHope :pierce
        @dice.bonus += attribute_bonus # modify the dice and return super
      end
    end     
    super   
  end
  

  def alive?
    return super && @wounds < 2
  end
  
  # tn to hit opponent
  def tnFor opponent
    @stance + opponent.defenses(self)
  end
  
  # tn to get hit
  def tn opponent
    @stance + self.defenses(opponent)
  end
  
  
  
  
  def weary?
    super || (self.encumbrance >= @current_endurance)
  end
  
  def attackRoll
    @dice.roll( self.weapon_skill, self.isWeary, 0 )
    return d
  end
end   

