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
  
  def self.addEvent actor, type, params=nil
    if actor.token && (@@records.include? actor.token)
      record = @@records[actor.token][:records].last
      if record
        record.addEvent( actor, type, params )
        return true
      end
    end
    return false
  end
  
  def lastDice
    i=1
    while(i <= @events.size)
      d = @events[@events.size-i][:params][:dice]
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
        actor = event[:actor]
        if !results[actor]
          newEntry = {:hits=>0, :pierced=>0, :weary=>0, :hope=> {}}
          results[actor] = newEntry
        end
        result = results[actor]
        type = event[:type]
        
        if type == :attack
          event[:params][:dice].test( event[:params][:tn] )
          result[:hits] +=  (event[:params][:dice].test event[:params][:tn] ) ? 1 : 0
          result[:weary] += event[:params][:dice].weary ? 1 : 0  
        end
        
        if type == :hope
          type = event[:params][:type]
          result = result[:hope]
        end
        
        if type == :armor_check
          if !(event[:params][:dice].test event[:params][:tn])
            result[:pierced] +=1
          end
        end
        
        if !result[type]
          result[type] = 1
        else
          result[type] += 1
        end
      end
    end
    results
  end
       
  
  def addEvent( actor, type, params )
    h = { :actor => actor, :type => type, :params => params }
    @events.push h
  end
  
  def to_html
    result = ""
    @events.each do | event |
      result += "<br>"
      if( event[:type] != :attack )
        result += "--"
      end
      
      name = event[:actor].name
      
      case event[:type]
      when :attack  
        if( event[:params][:called] )
          result += "#{name} attempts a <b>called shot</b> and rolls #{event[:params][:dice]} (vs. #{event[:params][:tn]})"
        else
          result += "#{name} attacks and rolls #{event[:params][:dice]} (vs. #{event[:params][:tn]})"
        end
      when :pierce 
        result += "Pierce!"
      when :hate
        case event[:params][:type]
        when :craven
          result += "#{name} is <b><i>craven</i></b> and tries to flee!"
        else
          result += "#{name} uses its <b><i>#{event[:params][:type].to_s.gsub('_',' ').capitalize}</i></b>"
        end
      when :hound_of_mirkwood
        result += "#{name}'s <b>Hound of Mirkwood</b> takes the wound for its master."
      when :hope
        hope_left = event[:params][:hope_left]
        case event[:params][:type]
        when :protection
          result += "#{name} spends <b>Hope</b> to avoid a wound. (#{hope_left} left)"
        when :tengwar
          result += "#{name} spends <b>Hope</b> (#{hope_left} left) to turn a miss into a great or extraordinary success."
        when :pierce
          result += "#{name} spends <b>Hope</b> (#{hope_left} left) to turn a miss into a pierce."
        end
      when :disarmed
        result += "#{name} is <b>disarmed</b>!"
      when :fumble
        result += "#{name} fumbles the called shot. What a nub."
      when :called_shot
        result += "#{name} attempts a <b><i>Called Shot</i></b>!"
      when :knockback
        result += "#{name} rolls with the blow for half damage."
      when :armor_damage
        result += "#{name}'s armor gets damaged! (#{event[:params][:armor_left]} left)."
      when :skip
        result += "#{name} misses a turn."
      when :out_of_hate
        result += "#{name} is out of Hate!"
      when :called_shot
        result += "Called Shot!"
      when :armor_check
        result += "#{name} rolls armor: #{event[:params][:dice]} vs. #{event[:params][:tn]}"
      when :wound
        result += "#{name} is <b>wounded</b> (#{event[:params][:wounds]} total)"
      when :dies
        result += "#{name} dies."
      when :damage
        result += "#{name} <b>takes #{event[:params][:amount]} damage</b> (#{event[:params][:health_left]} left)."
      else
        result += event.to_s + " not handled."
      end
            
    end
    result
  end
  
end