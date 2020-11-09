require "open-uri"

class GamesController < ApplicationController

  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start_time = DateTime.now
  end

  def score
    # binding.pry
    suggestion = params[:suggestion]
    letters = params[:letters]
    end_time = DateTime.now
    start_time = params[:start].to_datetime
    @result = run_game(suggestion, letters, start_time, end_time)
  end

private

  def included?(suggestion, letters)
    suggestion.chars.all? { |letter| suggestion.count(letter) <= letters.count(letter) }
  end

  def compute_score(suggestion, time_taken)
    time_taken > 60.0 ? 0 : suggestion.size * (1.0 - time_taken / 60.0)
  end

  def run_game(suggestion, letters, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    result = { time: ((end_time - start_time)*24*60*60).to_i }

    score_and_message = score_and_message(suggestion, letters, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(suggestion, letters, time)
    if included?(suggestion.upcase, letters)
      if english_word?(suggestion)
        score = compute_score(suggestion, time)
        [score, "well done"]
      else
        [0, "not an english suggestion"]
      end
    else
      [0, "not in the letters"]
    end
  end

  def english_word?(suggestion)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{suggestion}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
