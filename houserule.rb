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
        :name => "Angelaxe's Rule (Monsters)",
        :tooltip => "Fair is fair, right?"
      }
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