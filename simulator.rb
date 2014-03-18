require 'rubygems'
require 'sinatra'
require 'sinatra/partial'
require 'haml'

Dir["./monsters/*"].each {|file| require file }
Dir["./heroes/*"].each {|file| require file }



def deathmatch( hero, bunchOfMonsters, iterations )
  iterations.times do | i |
    FightRecord.newFight hero.token
    hero.reset
    bunchOfMonsters.each do | m |
      m.reset
    end
    
    monsters = bunchOfMonsters.dup

    if( rand(2) == 1 )
      hero.attack( monsters )
    end
        
    while( hero.alive? && monsters.size > 0 )
      monsters.each do | m |
        m.attack( hero )
        if !hero.alive?
          break
        end
      end
      if hero.alive?
        hero.attack( monsters )
      end
    end
  end
end

def statsToHtml compiledStats
  result = "<table padding=5 border=1>"
  result += "<tr><th>Name</th><th>Win</th><th>Hit</th><th>Weary</th><th>Prot Rolls</th><th>Resist</th></tr>"
  
  compiledStats.keys.sort.each do |key|
    entry = compiledStats[key]
    result += "<tr>"
    result += "<td>" + key.to_s + "</td>"
    h = entry[:hits]
    m = entry[:misses]
    p = entry[:pierces]
    w = entry[:wounds]
    d = entry[:deaths]
    weary = entry[:weary]
    result += "<td align=center>" + ((10000 - d) / 100).to_s + "%</td>"
    result += "<td align=center>" + (h * 100 / (h + m)).to_s + "%</td>"
    result += "<td align=center>" + (weary * 100 / (h + m)).to_s + "%</td>"
    result += "<td align=center>" + p.to_s + "</td>"
    result += "<td align=center>" + ((p - w) * 100 / p).to_s + "%</td>"
    result += "</tr>"
  end
  result += "</table>"
  result
end
  

get '/index' do
  @foo = "bar"
  erb :index
end

get '/submit_button' do
  title = "Fight!"
  case params["culture"]
  when "Beorning"
    title = '"Rawwwrrr!!!"'
  when "Barding"
    title = '"Go now and speed well!"'
  when "EreborDwarf"
    title = '"Khazad Dummmmm!"'
  when "MirkwoodElf"
    title = '"Ai Ai! A Balrog!"'
  when "ShireHobbit"
    title = '"Attercop! Attercop!"'
  when "Woodman"
    title = '"Release the Hounds!"'
  end
  
  partial :submit_button, :layout => false, :locals => { :title => title }
end

get '/' do
#  @b = Beorning.spearman

  haml :index

#  "Player Wins " + (playerWins * 100 / iterations).to_s + "% of the time."

end

# get('/'){ haml :index }
get('/response'){  "Hello from the server" }
get('/time'){ "The time is " + Time.now.to_s }

post('/setculture') do
  partial( :heroform, :layout => false, :locals => {:culture=>params["culture"], :params=>params } )
  #"[Foo, Bar, Baz]"
end

get('/monstertype') do
  partial( :monstertype, :layout => false, :locals => {:monsterclass => params["monsterclass"]})
end

get('/backgrounds') do
  partial( :backgrounds, :layout => false, :locals => {:culture => params["culture"]})
end

get('/gear') do
  culture = ( (params.keys.include? "culture") ? params["culture"] : "Hero" )  
  reward = ((params.keys.include? "reward") ? params["reward"] : "none" )
  if params.keys.include? "type"
    partial( :geartype, :layout => false, :locals => {:type => params["type"], :culture => culture, :reward=>reward})
  else
    partial( :gear, :layout => false, :locals => {:culture => culture})
  end
end

get('/attributes') do
  partial( :attributes, :layout => false, :locals => {:attributes =>{:body => params[:body], :heart => params[:heart], :wits => params[:wits]}})
end

get('/feats') do
  partial( :feats, :layout => false, :locals => { :culture => params[:culture]})
end

get('/monsterstats') do
  if !params.include? 'monstertype'
    partial( :monsterstats, :layout => false, :locals => { :stats => {}})
  else
    monster = Monster.fromParams params
    partial( :monsterstats, :layout => false, :locals => { :monsterclass => params["monsterclass"], :stats => monster.to_hash })
  end
end

post('/masterform') do
  
  ["monsterclass", "monstertype", "culture", "background"].each do |p|
    if (!params.include? p) || (params[p] == "None" )
      return "<b>Please pick a culture, a background, and an opponent.</b>"
    end
  end
  
  puts "IP address: #{request.ip}"
  
  token = FightRecord.generate_token
  hero = Hero.fromParams params
  h = hero.to_hash
  hero.token = token
  monstercount = params["monstercount"].to_i
  monsters = []
  monstercount.times do |i|
    monster = Monster.fromParams params
    monsters.push monster
    monster.name = monster.name + (i+1).to_s
    monster.confirmAbilities params # can't do this inside constructor
    monster.token = token
  end
  iterations = 10**(params["iterations"].to_i)
  deathmatch( hero, monsters, iterations  )  
  
  if iterations == 1
    return (FightRecord.lastFightFor token).to_html   # turn this into a partial at some point
  end
  
  #otherwise return stats page
  partial( :stats, :locals => { :iterations => iterations, :stats => FightRecord.compile(token)})
  
end

post('/sethero') do
 iterations = params[:iterations].to_i
  hero = Hero.fromParams params
  deathmatch( hero, (Spider.createType :tauler, :beak), iterations )  
end




post('/setbackground') do
  partial( :weaponform, :layout => false, :locals => { :background => params[:background], :culture => params[:culture], :params => params} )
end

post('/setfeatsandbackground') do
  partial( :weaponform, :layout => false, :locals => {:culture => params[:culture], :params => params} )
end

=begin 
post('/sethero') do
  hero = Object::const_get(params[:culture])
  hero.Class.to_s
  "test"
end
=end
post('/reverse'){ params[:word].reverse }

  
