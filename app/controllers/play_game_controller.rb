require 'json'
require 'open-uri'

class PlayGameController < ApplicationController
  def game
    @guess = []
    10.times do
      @guess << ("A".."Z").to_a[rand(26)]
    end
    @guess = @guess.join
  end

  def score
    @attempt = params[:query]
    @grid = params[:grid].split("")
    run_game(@attempt, @grid)
  end

 def run_game(attempt, grid)
    @attempt_split = attempt.split("")
    @hash = {}
    @hash[:attempt] = attempt


    if !(@attempt_split.all? { |letter| @grid.map(&:downcase).count(letter) >= @attempt_split.map(&:downcase).count(letter) })
      @hash[:score] = 0
      @hash[:message] = "not in the grid"
      @hash[:translation] = nil
    else
      api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{@attempt}"
      open(api_url) do |stream|
        translation = JSON.parse(stream.read)
        if translation.key?('term0')
          @hash[:translation] = translation['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
          @hash[:score] = @attempt.length.to_i
          @hash[:message] = "well done"
        else
          @hash[:translation] = nil
          @hash[:score] = 0
          @hash[:message] = "not an English word"
        end
      end
    end
  end
end

