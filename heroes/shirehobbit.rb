require './hero'

class ShireHobbit < Hero
  
  superclass.registerCulture self

  def self.cultureName
    "Hobbit of the Shire"
  end
  
  
  def self.enduranceBase
    16
  end
  
  def self.culturalBlessing 
    {
      :name => "Hobbit-sense", 
      :tooltip => "'When making a Wisdom roll, Hobbits can roll the Feat die twice, and keep the best result.'",
      :implemented => false
    } 
  end
  
  def piercingBlow?
    super || (self.weapon.qualities.include?(:kings_blade) && self.dice.tengwars > 0)
  end
  
  
  def self.hopeBase
    12
  end
  
  def parry opponent=nil
    p = super
    if(opponent && (opponent.size > 1) && (@feats.include? :small_folk))
      return p + @f_wits
    end
    p
  end
  
  def rollProtectionAgainst opponent
    if( @armor.qualities.include? :lucky)
      tn = opponent.weaponInjury
      self.dice.roll( self.protection[0], self.weary?, 1 )
      self.dice.bonus = self.protection[1]
      FightRecord.addEvent( @token, self.name, :pierce, nil, nil )
      FightRecord.addEvent( @token, self.name, :armor_check, @dice, tn )
      test = @dice.test tn
      if !test
        self.wound
      end      
    else
      super
    end
  end
  
  def fromParams params
    result = super
    if( params.keys.include? "lucky" )
      @armor.qualities.add :lucky
    end
    result
  end
  


  def self.virtues 
    result = super
    result[:art_of_disappearing] = {:name => "Art of Disappearing", :implemented => false}
    result[:brave_at_a_pinch] = {:name => "Brave at a Pinch", :implemented => false}
    result[:fair_shot] = {:name => "Fair Shot", :implemented => false}
    result[:tough_in_the_fibre] = {:name => "Tough in the Fibre", :implemented => false}
    result[:small_folk] = {:name => "Small Folk", :implemented => true, :tooltip => "Use Favoured Wits to compute Parry when fighting larger-than-hobbit-sized opponents."}
    result
  end
    
  def self.rewardGearData
    [
      { :base => :bow, :name => "Bow of the North Downs", :quality => :north_downs, :tooltip => "Unimplemented." },
      { :base => :short_sword, :name => "King's Blade", :quality => :kings_blade, :tooltip => "Automatic Pierce on Great or Extraordinary Success." },
      { :base => :modifier, :name => "Lucky Armour", :quality => :lucky, :tooltip => "On Protection rolls, roll Feat die twice and keep higher."},
    ]
  end
  
  def self.backgrounds
    result = Hash.new
    result[:restless_farmer] = {:name => "Restles Farmer", :body => 3, :heart => 6, :wits => 5}
    result[:too_many_paths_to_tread] = {:name => "Too Many Paths to Tread", :body => 4, :heart => 5, :wits => 5}
    result[:a_good_listener] = {:name => "A Good Listener", :body => 3, :heart => 7, :wits => 4}
    result[:witty_gentleman] = {:name => "Witty Gentleman", :body => 2, :heart => 6, :wits => 6}
    result[:bucklander] = {:name => "Bucklander", :body => 4, :heart => 6, :wits => 4}
    result[:tookish_blood] = {:name => "Tookish Blood", :body => 2, :heart => 7, :wits => 5}
    result
  end
  
  def wisdomCheck tn=14
    @dice.roll( @wisdom, self.weary?, 1)
    @dice.test tn
  end
  
  
end
