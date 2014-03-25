require './hero'

class EreborDwarf < Hero

  superclass.registerCulture self

  
  def self.cultureName
    "Dwarf of Erebor"
  end
  
  def self.culturalBlessing 
    {
      :name => "Redoubtable", 
      :tooltip => "'Dwarf characters calculate their Fatigue threshold by adding up the Encumbrance ratings of all the items they are carrying, and then subtracting their favoured Heart score from the total.'" , 
      :implemented => true 
      } 
  end
  
  def hit opponent
    if @dice.gandalf? && (self.weapon.hasQuality? :azanulbizar)
      opponent.addCondition :weary
    end
    super
  end
  
  def self.gear type=nil, symbol=nil
    result = super
    # this needs to be abstracted/generalized....
    if result.size > 1 && (!type || type == Weapon)
      result[:mattock] = Weapon.new( "Mattock", 8, 10, 18, 3, :two_handed, :smash_shield );
    end
    result
  end
    
  def self.rewardGearData
    [
      { :base => :great_axe, :name => "Axe of the Azanulbizar", :quality => :azanulbizar}, 
      { :base => :modifier, :name => "Dwarf-wrought Hauberk", :quality => :dwarf_wrought },
      { :base => :helm, :name => "Helm of Awe", :quality => :awe}
    ] 
  end 
  
  def calcEncumbrance
    super
    if @cultural_blessing_enabled
      @encumbrance = [@encumbrance - self.favoured_heart, 0].max
    end
    @encumbrance
  end
   
   def self.enduranceBase
     28
   end

   def self.hopeBase
     6
   end
   
   def self.virtues #modifiers applied to self
     super
#     super + [:broken_spells, :durins_way, :old_hatred, :ravens_of_the_mountain, :the_stiff_neck_of_dwarves ] 
   end

   def self.backgrounds
     result = Hash.new
     result[:a_life_of_toil] = {:name => "A Life of Toil",:body => 6, :heart => 2, :wits => 6}
     result[:far_trader] = {:name => "Far Trader",:body => 7, :heart => 2, :wits => 5}
     result[:bitter_exile] = {:name => "Bitter Exile",:body => 7, :heart => 3, :wits => 4}
     result[:eloquent_orator] = {:name => "Eloquent Orator",:body => 5, :heart => 4, :wits => 5}
     result[:a_lesson_in_revenge] = {:name => "A Lesson in Revenge",:body => 6, :heart => 3, :wits => 5}
     result[:a_penetrating_gaze] = {:name => "A Penetrating Gaze",:body => 6, :heart => 4, :wits => 4}
     result
   end
  
  
end
