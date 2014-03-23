require 'set'

class HouseRule
  
  @@active_rules = Set.new
  
  def self.rules
    {
      :belegs_rule => {
        :name => "Beleg's Rule",
        :tooltip => "Subtract Body score from Encumbrance, min 0."
      },
      :woodclaws_rule => {
        :name => "Woodclaw's Rule",
        :tooltip => "Max one extra success in Defensive Stance; max three in Forward."
      },
      :angelalexs_rule => {
        :name => "Angelalex's Rule (Players)",
        :tooltip => "Armor also reduces incoming damage by 1 per 1d of protection."
      },
      
      :angelalexs_rule_monsters => {
        :name => "Angelalexe's Rule (Monsters)",
        :tooltip => "Fair is fair, right?"
      },
      
      :avenues_rule => {
        :name => "Avenue's Rule",
        :tooltip => "Armor also increases Parry by 2 less than its armor rating (min 0). Heroes and Adversaries."
      },
      :avenues_rule_modified => {
        :name => "Modified Avenue's Rule",
        :tooltip => "Reduces by 3 (min 0) instead of 2."
      },
      :richs_rule => {
        :name => "Rich's Rule",
        :tooltip => "When a Sauron is rolled for a protection roll, your armor is damaged and has its value reduced by 1d (minimum zero)."
      }
#      ,
#      :elfcrushers_rule => {
#        :name => "Elfcrusher's Rule",
#        :tooltip => "A new skill, Armor, is added. It costs XP, not AP, and each rank reduces armor encumbrance by 2 (min 0)."
#      }
      
    }
  end
  
  def self.parseParams params
    @@active_rules = Set.new
    r = self.rules
    params.keys.each do | key |
      if r.keys.include? key.to_sym
        @@active_rules.add key.to_sym
      end
    end
  end
     
  def self.include? symbol
    @@active_rules.include? symbol
  end
         
end