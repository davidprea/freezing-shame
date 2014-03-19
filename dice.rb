class Dice
  
  attr_accessor :rolls, :feats, :weary, :mod, :bonus
  
  def initialize
    self.reset
  end
  
  def reset
    @feats = []
    @mod = 0
    @bonus = 0
    @weary = false
    @rolls = []
  end
  
  def sauron?
    self.feat == 0
  end
  
  def gandalf?
    self.feat == 12
  end
  
  def feat
    ((@mod < 0) ? @feats.min : @feats.max )
  end
  
  def to_s   
    returnString = "("
    
    if @mod == 0
      if self.sauron?
        returnString += "S"
      elsif self.gandalf?
        returnString += "G"
      else
        returnString += self.feat.to_s 
      end
    else
      greyed_out = (self.feat == feats[0] ? 1 : 0)
      2.times do |i|
        if i == greyed_out
          returnString += "<span style='color:grey'>"
        end
        case @feats[i]
        when 0
          returnString += "S"
        when 12
          returnString += "G"
        else
          returnString += @feats[i].to_s
        end
        if i == greyed_out
          returnString += "</span>"
        end

        returnString += ( i == 0 ? ':' : '' ) # colon in between
      end
          
    end
    
    returnString += "|" 
    @rolls.each do |i|
      returnString += i.to_s
    end
    returnString += ")"
    
    if @bonus != 0
      returnString += "["
      returnString += ((@bonus > 0) ? '+' : '-')
      returnString += @bonus.to_s
      returnString += "]"
    end
    
    returnString += "="
    
    #total
    
    if self.gandalf?
      returnString += "A"
    elsif self.sauron?
      returnString += "F"
    else
      returnString += self.total.to_s
    end
    
    if !self.sauron?
      returnString += (["","+","++"][[self.tengwars,2].min]).to_s
    end
    
    return returnString
  end
  
  def statsTest( dice, tn, weary=false )
    wins = 0
    eyes = 0
    10000.times do |i|
      self.reset
      self.roll( dice, weary )
      puts self.to_s
      if self.sauron?
        eyes += 1
      end
      wins += ((self.test tn) ? 1 : 0)
    end
    puts "win: " + (wins / 100).to_s + "%"
    puts "Saurons: " + eyes.to_s
  end
                
  def test( tn )
    if self.sauron?
      return false
    elsif self.gandalf? || (self.total >= tn)
      return true
    else
      return false
    end
    false
  end
  
  def total
    self.feat + ((@rolls.length > 0) ? @rolls.inject{|sum,x| sum + x } : 0) + @bonus
  end
  
  def tengwars
    [self.allTengwars, 2].min
  end
  
  def allTengwars
    @rolls.count{ |d| d == 6 }
  end
  
  def clone
    d = Dice.new
    d.feats = @feats.dup
    d.rolls = @rolls
    d.weary = @weary
    d.mod = @mod
    d.bonus = @bonus
    d
  end
  
  def roll(dice, weary=false, feat_mod=0)
    self.reset
    @weary = weary
    @feats.push(rand(12) + 1)
    @mod = feat_mod

    # mod == 1 means roll feat twice take highest, options == -1 means take lowest
    if @mod != 0
      @feats.push( rand(12) + 1 )
    end
    
    @feats = @feats.map{|d| d == 11 ? 0 : d }
    
    
    dice.times do
      roll = rand(6) + 1
      if @weary && roll < 4
        roll = 0
      end
 
      @rolls.push roll
    end
  end
end