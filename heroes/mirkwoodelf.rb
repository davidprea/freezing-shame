require './hero'

class MirkwoodElf < Hero

  superclass.registerCulture self

  def self.cultureName
    "Elf of Mirkwood"
  end
  
  def self.enduranceBase
    22
  end
  
  def self.culturalBlessing 
    {
      :name => "Folk of the Dark", 
      :tooltip => "'When an Elf of Mirkwood is inside a forest or under the earth, or it is night, all his Attribute bonuses are based on his favoured rating.'", 
      :implemented => false
    } 
  end
  
  def self.hopeBase
    8
  end
  
  def self.virtues #modifiers applied to self
    super
    # super + [:deadly_archery, :elvish_dreams, :shadow_bane, :the_speakers, :woodelf_magic ] 
  end
  
  def weaponInjury
    if @dice.gandalf? && (self.weapon.hasQuality? :bitter)
      super + 4
    else
      super
    end
  end
  
  def shieldValue
    if @shield && (self.shield.hasQuality? :spearmans)
      @shield.value
    else
      super
    end
  end
  
  
  def self.rewardGearData
    [
      { :base => :spear, :name => "Bitter Spear", :quality => :bitter, :tooltip => "On G-roll, Injury rating increased by 4." },
      { :base => :buckler, :name => "Spearman's Shield", :quality => :spearmans, :tooltip => "Can be used with two-handed weapons." },
      { :base => :bow, :name => "Woodland Bow", :quality => :woodland, :tooltip => "Unimplemented." }
    ]
  end
  
  
  def self.backgrounds
    result = Hash.new
    result[:newhope] = {:name => "New Hope", :body => 5, :heart => 2, :wits => 7}
    result[:amusicallegacy] = {:name => "A Musical Legacy", :body => 5, :heart => 4, :wits => 5}
    result[:memoryofsuffering] = {:name => "Memory of Suffering", :body => 5, :heart => 3, :wits => 6}
    result[:nobleblood] = {:name => "Noble Blood", :body => 4, :heart => 4, :wits => 6}
    result[:wildatheart] = {:name => "Wild at Heart", :body => 4, :heart => 3, :wits => 7}
    result[:envoyoftheking] = {:name => "Envoy of the King", :body => 6, :heart => 2, :wits => 6}
    result
  end
  
  
end
