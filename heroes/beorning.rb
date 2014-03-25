require './hero'


class Beorning < Hero
  
  superclass.registerCulture self
    
  def initialize
    super
  end
  
  def self.virtues #modifiers applied to self
    super
    #super + [:brothers_to_bears, :night_goer, :skin_coat, :great_strength, :twice_baked_honey_cakes ] 
  end
  
  def self.virtues 
    result = super
    result[:brothers_to_bears] = {:name => "Brothers to Bears", :implemented => false, :tooltip => "Unimplemented"}
    result[:night_goer] = {:name => "Night-goer", :implemented => false, :tooltip => "Unimplemented"}
    result[:skin_coat] = {:name => "Skin-coat", :implemented => false, :tooltip => "Trade endurance for Protection bonus."}
    result[:great_strength] = {:name => "Great Strength", :implemented => true, :tooltip => "If your Fatigue rating is equal to or less than 12 you receive a bonus of +3 to your Parry score."}
    result[:twice_baked_honey_cakes] = {:name => "Twice-baked Honey Cakes", :implemented => false, :tooltip => "Unimplemented"}
    result
  end
  
  def tnFor opponent  # TN to hit
    target = @stance + opponent.parry
    if( opponent.size > 2 && (@weapon.hasQuality? :giant_slaying))
      target -= 4
    end
    target
  end
  
  def parry opponent=nil
    if( self.encumbrance < 12 && self.hasVirtue?(:great_strength))
       super + 3
    else
       super
    end
  end
  
  
  def self.culturalBlessing
    {
      :name => "Furious", 
      :tooltip => "'When a Beorning is wounded in battle, he ignores the effects of being Weary and Miserable for the duration of combat.'", 
      :implemented => true
    } 
  end
  
  
  
  def self.rewardGearData
    [
      {:base => :great_spear, :name => "Giant Slaying Spear", :quality => :giant_slaying, :tooltip => "+4 Damage vs. larger-than-human-sized opponents."},
      {:base => :great_axe, :name => "Splitting Axe (Great)", :quality => :splitting, :tooltip => "On G-roll, opponent rolls one fewer protection dice."},
      {:base => :axe, :name => "Splitting Axe", :quality => :splitting, :tooltip => "On G-roll, opponent rolls one fewer protection dice."},
      {:base => :leather_corslet, :name => "Noble Armour", :quality => :noble, :tooltip => "Unimplemented"}
    ]
  end   
  
  
  def self.backgrounds
    result = Hash.new
    result[:child_of_two_folk] = {:name => "Child of Two Folk", :body => 6, :heart => 6, :wits => 2}
    result[:errand_rider] = {:name => "Errand-rider", :body => 7, :heart => 5, :wits => 2}
    result[:head_of_the_family] = {:name => "Head of the Family", :body => 6, :heart => 4, :wits => 4}
    result[:light_foot] = {:name => "Light-foot", :body => 5, :heart => 5, :wits => 4}
    result[:keeper_of_tales] = {:name => "Keeper of Tales", :body => 6, :heart => 5, :wits => 3}
    result[:voice_from_the_past] = {:name => "Voice from the Past", :body => 7, :heart => 4, :wits => 3}
    result
  end

  def weary?
    (@cultural_blessing_enabled && @wounds > 0) ? false : super
  end
  
  def virtuesAndRewardsList
    super + [:giant_slaying_spear, :noble_armor, :splitting_axe, :skin_coat, :great_strength]
  end
  
  def self.enduranceBase
    24
  end
  
  def self.hopeBase
    8
  end
  
  
  
  def self.spearman
    b = Beorning.new
    b.name = "Beorning Spearman"
    b.setBody 6, 3 # value after comma is favoured bonus
    b.setWits 4, 2
    b.setHeart 4, 1
    b.weapon_skill = 3
    b.weapon = :great_spear
    b.armor = :mail_shirt
    b.shield = :none
    b.helm = :none
 #   b.armor = 3
    b.stance = 6
    return b 
  end
  
end
