require './hero'

class Woodman < Hero
  
  superclass.registerCulture self

  def self.enduranceBase
    20
  end
  
  def self.hopeBase
    10
  end
  
  def self.culturalBlessing 
    {
      :name => "Woodcrafty", 
      :tooltip => "'When the Woodmen fight in the woods, they use their favoured Wits score as their basic Parry rating.'", 
      :implemented => false
    } 
  end
  
  def self.virtues #modifiers applied to self
    super # + [:a_hunters_resolve, :herbal_remedies, :hound_of_mirkwood, :natural_watchfulness, :staunching_song ] 
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
  
  
end
