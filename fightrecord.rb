require './dice'

class FightRecord
  
  attr_accessor :events
  
  @@records = {}
  
  def initialize
    @events = []
  end
  
  def self.getRecords token
    @@records[token][:records]
  end
  
  def self.lastFightFor token
    @@records[token][:records].last
  end
  
  def self.generate_token
    token = ("t" + rand(100000).to_s).to_sym
    @@records[token] = { :time_stamp => Time.now, :records => [] }
    self.cleanup
    token
  end
  
  def self.newFight token
    if token && (@@records.include? token)
      records = @@records[token][:records]
      records.push( FightRecord.new )
      return true
    end
    return false
  end
  
  def self.cleanup
    @@records.keys.each do |key|
      t = @@records[key][:time_stamp]
      if (Time.now - t) > 60
        @@records.delete(key)
      end
    end
  end
  
  def self.addEvent token, name, type, dice, value=nil
    if token && (@@records.include? token)
      record = @@records[token][:records].last
      if record
        record.addEvent( name, type, dice, value )
        return true
      end
    end
    return false
  end
  
  def lastDice
    i=1
    while(i <= @events.size)
      d = @events[@events.size-i][:dice]
      if d
        return d
      end
      i += 1
    end
    puts "Error: no last dice in events"
    nil
  end
      
  def self.compile token
    array = self.getRecords(token)
    results = {}
    array.each do |record|
      record.events.each do |event|
        actor = event[:player]
        h = results[actor]
        if !h 
          h = {:hits=>0, :weary=>0, :hope=> {}}
          results[actor] = h
        end
        type = event[:type]
        
        if type == :attack
          event[:dice].test( event[:value] )
          h[:hits] +=  (event[:dice].test event[:value] ) ? 1 : 0
          h[:weary] += event[:dice].weary ? 1 : 0  
        end
        
        if type == :hope
          type = event[:value]
          h = h[:hope]
        end
        
        if !h[type]
          h[type] = 1
        else
          h[type] += 1
        end
      end
    end
    results
  end
       
  
  def addEvent( player, type, dice, value=0 )
    h = { :player => player, :type => type, :dice => ( dice ? dice.clone : nil), :value => value }
    @events.push h
  end
  
  def to_html
    result = ""
    @events.each do | event |
      result += "<br>"
      if( event[:type] != :attack )
        result += "--"
      end
      
      case event[:type]
      when :attack  
        result += event[:player] + " attacks and rolls " + event[:dice].to_s
      when :pierce 
        result += "Pierce!"
      when :hate
        case event[:value]
        when :craven
          result += event[:player] + " is <b><i>craven</i></b> and tries to flee!"
        else
          result += event[:player] + " uses its <b><i>" + event[:value].to_s + "</i></b>"
        end
      when :hope
        case event[:value]
        when :protection
          result += event[:player] + " spends <b>Hope</b> to avoid a wound."
        when :attack
          result += event[:player] + " spends <b>Hope</b> to turn a miss into a hit."
        end
      when :disarmed
        result += event[:player] + " is <b>disarmed</b>!"
      when :knockback
        result += "#{event[:player]} rolls with the blow for half damage."
      when :skip
        result += event[:player] + " misses a turn."
      when :out_of_hate
        result += event[:player] + " --is out of Hate!"
      when :called_shot
        result += "Called Shot!"
      when :armor_check
        result += event[:player] + " rolls armor: " + event[:dice].to_s + " vs. " + event[:value].to_s
      when :wound
        result += event[:player] + " is <b>wounded</b> (" + event[:value].to_s + " total)"
      when :dies
        result += event[:player] + " dies."
      when :damage
        result += event[:player] + " <b>takes " + event[:value].to_s + " damage</b>."
      when :health_remaining
        result += event[:player] + " has<b> " + event[:value].to_s + " health left</b>."
      else
        result += event.to_s + " not handled."
      end
            
    end
    result
  end
  
end