require_relative 'word_class.rb'

class Response
  attr_accessor :word, :response

  def initialize(the_word, the_response)
    @word = the_word
    @response = the_response
  end

  def make_words_syns_examples
    all_words = []
    if @response == nil
      return nil
    end
    @response.each do |one_word|
      all_words.push(Word.new(@word, one_word)) if one_word.include?("examples") && one_word.include?("synonyms")
    end
    all_words
  end

  def make_words_defs
    all_words = []
    if @response == nil
      return nil
    end
    @response.each do |one_word|
      all_words.push(Word.new(@word, one_word)) if one_word.include?("definition")
    end
    all_words
  end


end