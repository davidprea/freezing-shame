require 'rubygems'
require 'sinatra'
require 'sinatra/partial'
require 'haml'

Dir["./monsters/*"].each {|file| require file }
Dir["./heroes/*"].each {|file| require file }

def fight( opponent1, opponent2, resultString )
  
  opponent1.reset
  opponent2.reset
  
  result = {}
  
  rounds = 0
  
  while opponent1.alive? && opponent2.alive?
    rounds += 1
    resultString = opponent1.attack( opponent2, resultString )
    if opponent2.alive?
      resultString = opponent2.attack( opponent1, resultString )
    end
  end
  resultString
end

def deathmatch( opponent1, opponent2, iterations )
  resultString = nil
  playerWins = 0
  iterations.times do | i |
    if i==(iterations-1)
      resultString = ""
    end
    if( rand(2) == 1 )
      resultString = fight(opponent1,opponent2,resultString)
    else
      resultString = fight(opponent2,opponent1,resultString)
    end
    [opponent1,opponent2].each do | p |
      p.name + (p.alive? ? (" wins with " + (p.endurance * 100 / p.maxEndurance).to_s + "% health.") : " dies.")
    end
    if opponent1.alive?
      playerWins+=1
    end
  end
  resultString += "<p> Player wins: " + (playerWins * 100.0 / iterations).round(1).to_s + "%."
  resultString
end

get '/index' do
  @foo = "bar"
  erb :index
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
  puts "Set culture fired!"
  puts params
  partial( :heroform, :layout => false, :locals => {:culture=>params["culture"], :params=>params } )
  #"[Foo, Bar, Baz]"
end

post('/sethero') do
  puts "Set hero fired! Values:"
  params.keys.each do |key|
    puts key.to_s + "(" + key.class.to_s + ") : " + params[key]
  end
  iterations = params[:iterations].to_i
  puts "Iterations: " + iterations.to_s
  hero = Hero.fromParams params
  puts "Hero: " + hero.to_s
  deathmatch( hero, (Orc.createType :chieftan, :orc_axe), iterations )  
end


post('/setbackground') do
  puts "Set backbround fired!"
  puts "Background: " + params.to_s
  partial( :weaponform, :layout => false, :locals => { :background => params[:background], :culture => params[:culture], :params => params} )
end

post('/setfeatsandbackground') do
  puts "Set feats fired!"
  puts "Feats: " + params.to_s
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

  
