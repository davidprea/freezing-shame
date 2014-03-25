require './hero'

class Woodman < Hero
  
  superclass.registerCulture self

  def self.enduranceBase
    20
  end
  
  def self.hopeBase
    10
  end
  
  def hit_by? opponent
#    puts "Hit Check.  virtues: #{self.feats.to_a.join(', ')}"
    if opponent.dice.gandalf? && self.hasVirtue?(:hound_of_mirkwood) && !self.hasCondition?( :hound_of_mirkwood_wounded )
      self.addCondition( :hound_of_mirkwood_wounded )
      FightRecord.addEvent( self, :hound_of_mirkwood, nil )
      return false
    end
    super
  end
  
  
  def self.culturalBlessing 
    {
      :name => "Woodcrafty", 
      :tooltip => "'When the Woodmen fight in the woods, they use their favoured Wits score as their basic Parry rating.'", 
      :implemented => false
    } 
  end
  
  def self.virtues 
    result = super
    result[:a_hunters_resolve] = {:name => "A Hunter's Resolve", :implemented => true, :tooltip => "Spend a Hope point to recover a number of Endurance points equal to your favoured Heart rating (triggers on Weary)."}
    result[:herbal_remedies] = {:name => "Herbal Remedies", :implemented => false, :tooltip => 
    "Unimplemented." }
    result[:hound_of_mirkwood] = {:name => "Hound of Mirkwood", :implemented => true, :tooltip => "When you are engaged in battle, if an attack aimed at you produces a Eye of Sauron result, the blow hits and automatically wounds the hound instead (in place of the effects of a normal hit)."}
    result[:natural_watchfulness] = {:name => "Natural Watchfulness", :implemented => false, :tooltip => "Unimplemented"}
    result[:staunching_song] = {:name => "Staunching Song", :implemented => false, :tooltip => "Unimplemented"}
    result
  end
  
    
  def self.rewardGearData
    [
      { :base => :long_hafted_axe, :name => "Bearded Axe", :quality => :bearded },
      { :base => :modifier, :name => "Feathered Armour", :quality => :feathered },
      { :base => :bow, :name => "Shepherds-bow", :quality => :shepherds },
      { :base => :great_bow, :name => "Shepherds-bow (Great)", :quality => :shepherds }
    ]
  end
  
  def self.backgrounds
    result = Hash.new
    result[:the_hound] = {:name => "The Hound", :body => 3, :heart => 4, :wits => 7}
    result[:wizards_pupil] = {:name => "Wizard's Pupil", :body => 3, :heart => 5, :wits => 6}
    result[:fairy_heritage] = {:name => "Fairy Heritage", :body => 4, :heart => 4, :wits => 6}
    result[:apprentice_to_the_mountain_folk] = {:name => "Apprentice to the Mountain-folk", :body => 4, :heart => 5, :wits => 5}
    result[:seeker] = {:name => "Seeker", :body => 2, :heart => 5, :wits => 7}
    result[:sword_day_counsellor] = {:name => "Sword-day Counsellor", :body => 2, :heart => 6, :wits => 6}
    result
  end
  
  def takeDamage opponent, amount
    super
    if @current_endurance <= self.encumbrance && @current_hope > 0 && self.hasVirtue?(:a_hunters_resolve) && !self.hasCondition?(:used_hunters_resolve)
      self.spendHope :hunters_resolve
      self.addCondition( :used_hunters_resolve )
      @current_endurance += self.favoured_heart
    end
  end
      
      
      
      
  
end
