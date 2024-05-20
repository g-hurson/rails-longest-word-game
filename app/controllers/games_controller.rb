require "json"
require "open-uri"

class GamesController < ApplicationController
  def new
    @letters = []
    10.times {@letters << ("A".."Z").to_a.sample}
    @start_time = Time.now
    @letters
  end

  def score
    @score = session[:score] || 0
    @delay = (Time.now - params[:start_time].to_time).round
    if !ok_grid
      @message = "Sorry, but the test can be built out of #{params[:letters].split.join(", ")}"
    elsif !api_call
      @message = "Sorry, but #{params[:word]} does not seem to be a valid English word"
    else
      @message = "Congratulations! #{params[:word]} is a valid English word! You found it in #{@delay} seconds !"
      @score += params[:word].size
      # @score += ((params[:word].size * 40) / @delay.to_f).to_i
    end
    session[:score] = @score
  end

  private
  def api_call
    url = "https://dictionary.lewagon.com/#{params[:word]}"
    word_serialized = URI.open(url).read
    word = JSON.parse(word_serialized)
    return word["found"]
  end

  def ok_grid
    word_array = params[:word].upcase.chars
    grid = params[:letters].split(" ")
    check_grid = word_array.all? { |letter| grid.include?(letter) }
    if check_grid
      word_array.tally.each { |k, v| check_grid = check_grid && (grid.tally[k] >= v ) }
    end
    return check_grid
  end
end
