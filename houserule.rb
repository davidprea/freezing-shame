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
        :name => "Avenue's Rule, Modified",
        :tooltip => "Protection minus 3 instead of 2."
      },
      :richs_rule => {
        :name => "Rich's Rule",
        :tooltip => "When a Sauron is rolled for a protection roll, your armor is damaged and has its value reduced by 1d (minimum zero)."
      },
      :vengers_rule => {
        :name => "Venger's Rule",
        :tooltip => "Adversaries only use Snake-like Speed against Great/Extraordinary Successes and against Pierce."
      },
      :michebugios_rule => {
        :name => "Michebugio's Rule",
        :tooltip => "An attack that results in an Extraordinary Success becomes a Piercing blow (but only gets a single damage bonus)."
      },
      :yepesnopes_rule => {
        :name => "Yepesnopes' Rule",
        :tooltip => "Reduce all Edge ratings, for heros and monster, by 1."
      },
      :tomfish_rule => {
        :name => "Tomfish's Rule",
        :tooltip => "When Wounded, roll Feat die twice and take lower result."
      },
      :evenings_rule => {
        :name => "Evening's Rule",
        :tooltip => "Roll protection on every non-pierce. Reduce damage by 1 for each tengwar, +1 for mail, 0 on Eye. Knocked back on total failure."
      }     ,
      :elfcrushers_rule => {
        :name => "Elfcrusher's Rule",
        :tooltip => "Armor encumbrance only accrues while traveling (use Travel Fatigue to simulate values > 0.)"
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