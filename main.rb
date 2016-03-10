require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'asdfsdfasdf' 
helpers do
  
  def total_value(cards)
    total_points = 0
    ace = 0
    arr = cards.map{|element|element[1]}
    
    arr.each do |card|
      case card
      when "A"
        total_points += 11
        ace += 1
       when "10", "J", "Q", "K"
      total_points += 10
      when "2", "3", "4", "5", "6", "7", "8", "9"
      total_points += card.to_i
      end
    while total_points > 21 && ace > 0
      total_points -= 10
      ace -= 1
      end
    end
  total_points
    end

  def card_image(card) #["H","8"]
    suit = case card[0]
    when "C" then "clubs"
    when "D" then "diamonds"
    when "H" then "hearts"
    when "S" then "spades"
    end

    value = card[1]
      if ['J','Q',"K","A"].include?(value)
        value = case card[1]
        when "J" then "jack"
        when 'Q' then "queen"
        when 'K' then "king"
        when "A" then 'ace'
        end
      end
        "<img src=' /images/cards/#{suit}_#{value}.jpg' class = 'card_image'>"
      end

      def winner!(msg)
        @stay_hit_button = false
        @success = "<strong>#{session[:player_name]} wins!</strong> #{msg}"
        @game_over_button = true
      end

      def loser!(msg)
        @stay_hit_button = false
        @error = "<strong>#{session[:player_name]} loses!</strong> #{msg}"
        @game_over_button = true
      end

      def tie!(msg)
        @stay_hit_button = false
        @success = "<strong>It's Tie</strong> #{msg}"
        @game_over_button = true
      end

end



before do
  @stay_hit_button = true
end

BLACKJACK_AMOUNT = 21
DEALER_AMOUNT = 17
get '/' do
  if session[:player_name]
    redirect '/game'
  else
  redirect '/new_player'
  end
end

get '/new_player' do
  erb :player_form
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "you must type name"
    halt erb(:player_form)
  end

  session[:player_name] = params[:player_name]
  redirect '/game'
  end

get '/game' do
  session[:turn] = session[:player_name]
  suits = ["H","D", "C", "S"]
  values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  player_points = total_value(session[:player_cards])
  if player_points == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack")
    erb :game
  else
    erb :game
  end

end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  player_points = total_value(session[:player_cards])
    if player_points == BLACKJACK_AMOUNT
      winner!("#{session[:player_name]} hit blackjack, #{session[:player_name]} Win")
  elsif(player_points > BLACKJACK_AMOUNT)
    loser!("sorry, you are busted")
  else
    erb :game
  end
  erb :game
end

post '/game/player/stay' do
  @success = " you choose to stay!"
  @stay_hit_button = false
  redirect '/game/dealer' 
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @stay_hit_button = false
  dealer_total = total_value(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("Sorry, dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Congratulations, dealer busted.")
  elsif dealer_total >= DEALER_AMOUNT #17, 18, 19, 20
    # dealer stays
    redirect '/game/compare'
  else
    # dealer hits
    @dealer_stay_hit_button = true
  end
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @dealer_stay_hit_button = false
  player_points = total_value(session[:player_cards])
  dealer_points = total_value(session[:dealer_cards])
  
  if player_points < dealer_points
    loser!("Sorry.#{session[:player_name]} Lost")
  elsif player_points > dealer_points
    winner!("Congrats.#{session[:player_name]} Win!")
  else
    tie!("It's tie!")
  end

  erb :game
end

get '/game_over' do
  erb :game_over

end
