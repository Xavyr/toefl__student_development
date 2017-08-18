require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require 'unirest'
require 'json'
require 'rerun'
require "sinatra/reloader" if development?
load 'classes/sat.rb'
load 'classes/response_class.rb'
load 'classes/word_class.rb'
load 'classes/toefl_class.rb'
 

get "/home" do
  erb :home
end


get "/synonym" do
  if !(params.include?("answer"))
    intialize_params
  end
  params[:loc] = "syn"
  tally_score
    
  @set_of_words = recieve_word_from_word_api(4, 'syn')
  @main_word = @set_of_words[0]
  p @main_word  
  @first_word = @set_of_words[1] 
  p @first_word 
  @second_word = @set_of_words[2]
  p @second_word  
  @third_word = @set_of_words[3] 
  p @third_word 

  erb :synonym
end

get "/mistaken/:wrong_answers/:right/:wrong/:attempts/:loc" do
  #the first if and @missed_set is for toefl wrongs...
  @missed_set = []
  if params[:loc] == 'toefl'
    toefl_set = ToeflQuestions.new
    @incorrects = params[:wrong_answers].split(' ')
    @incorrects.each do |guess_key|
      @missed_set.push(toefl_set.get_specific_question(guess_key))
    end
    p @missed_set.to_s
  else #this is for defs and synonyms- the same needs to happen for both
    @incorrects = params[:wrong_answers].split(' ')
    p @incorrects
    @incorrect_data = call_api_specifically_for(@incorrects, params[:loc]).flatten!
    p @incorrect_data
  end
  erb :incorrects
end

get "/definition" do
  if !(params.include?("answer"))
    intialize_params
  end 
  params[:loc] = "def"
  tally_score

  @set_of_words = recieve_word_from_word_api(5, 'def')

  @main_word = @set_of_words[0]
  p @main_word  
  @first_word = @set_of_words[1] 
  p @first_word 
  @second_word = @set_of_words[2]
  p @second_word  
  @third_word = @set_of_words[3] 
  p @third_word
  @fourth_word = @set_of_words[4]
  p @fourth_word

  erb :definition 
end

get '/cores' do 
  if !(params.include?("answer"))
    intialize_params
  end 
  params[:loc] = "cores"
  tally_score

  @passage_word = File.read('data/core_data/manipulated_files/core_words_found_in_passages.txt').split(' ').sample
  @core_sentences_set = retrieve_sentence(@passage_word)
  
  response = make_call(@passage_word)
  json_body = JSON.parse(response.raw_body)
  word = json_body["word"]
  results_array = json_body["results"]
  my_response = Response.new(word, results_array)

  @main_word = my_response.make_words_defs.sample
  @set_of_words = recieve_word_from_word_api(3, "def")
  @set_of_words.push(@main_word)

  p @set_of_words  
  erb :cores
end

get '/toefl' do
  if !(params.include?("answer"))
    intialize_params
  end 
  params[:loc] = "toefl"
  tally_score

  toefl_class_question_set = ToeflQuestions.new
  random_question = toefl_class_question_set.generate_random_question
  #I'm printing to case any question that breaks the program so I can revise the data
  #impossible to know if the data is totally clean. I think i need this if check for nils that bust the program
  if random_question.include?(nil)
    random_question.delete(nil)
  end
  p random_question

  @key = random_question[0]
  @correct_answer = "(" + random_question[1] + ")"
  @question = random_question[2]
  @possible_answers = random_question[3].split("\n")
  #if statement is just to check any oddities...if possible... with answer string as
  #originally recieved
  if @possible_answers[0] == ""
    @possible_answers.shift
  end


  erb :toefl
end

not_found do 
  redirect "/home"
end

def intialize_params 
  params[:right] = 0
  params[:wrong] = 0
  params[:attempts] = 0
  params[:main_word] = ""
  params[:wrong_answers] = ""
  params[:last_word] = ""
end

def tally_score
  if params["answer"] == 'correct'
    params[:right] = params[:right].to_i + 1
    params[:attempts] = params[:attempts].to_i + 1
  elsif params["answer"] == 'incorrect'
    params[:wrong] = params[:wrong].to_i + 1
    params[:attempts] = params[:attempts].to_i + 1
    params[:wrong_answers] = params[:wrong_answers] + " " + params[:last_word]
  else
    "nothing"
  end
end

def recieve_word_from_word_api(number_of_words, delimiter)
  selected_words = []
  if delimiter == 'syn'
    (number_of_words).times do 
      my_response = nil
      loop do 
        new_word = get_new_word()
        p new_word

        response = make_call(new_word)

        json_body = JSON.parse(response.raw_body)
        word = json_body["word"]
        results_array = json_body["results"]

        my_response = Response.new(word, results_array)

        break if !(results_array.nil?) && my_response.make_words_syns_examples.size > 0 
      end
      selected_words.push(my_response.make_words_syns_examples.sample)
    end
  elsif delimiter == 'def'
    (number_of_words).times do 
      my_response = nil
      loop do 
        new_word = get_new_word()
        p new_word

        response = make_call(new_word)

        json_body = JSON.parse(response.raw_body)
        word = json_body["word"]
        results_array = json_body["results"]

        my_response = Response.new(word, results_array)

        break if !(results_array.nil?) && my_response.make_words_defs.size > 0 
      end
      selected_words.push(my_response.make_words_defs.sample)
    end
  else
  end
  selected_words
end 

def call_api_specifically_for(incorrects, delimiter)
  all_data = []
  if delimiter == "syn"
    incorrects.each do |word|
      response = make_call(word)
      json_body = JSON.parse(response.raw_body)
      word = json_body["word"]
      results_array = json_body["results"]

      my_response = Response.new(word, results_array)
      all_data.push(my_response.make_words_syns_examples)
    end
  elsif delimiter == "def" || delimiter == "cores"
    incorrects.each do |word|
      response = make_call(word)
      json_body = JSON.parse(response.raw_body)
      word = json_body["word"]
      results_array = json_body["results"]

      my_response = Response.new(word, results_array)
      all_data.push(my_response.make_words_defs)
    end
  else
  end
  
  all_data
end

def get_new_word
  sat_array = Sat.new
  sat_array.draw_word
end

def get_new_core_word_set
  core_word_array = CoreWordClass.new
  core_word_array.draw_word
end

def make_call(new_word)
  response = ""
  debug_int = 0
  loop do 
    # These code snippets use an open-source library. http://unirest.io/ruby PUT #{sampled} where rabid is
    response = Unirest.get "https://wordsapiv1.p.mashape.com/words/#{new_word}",
      headers:{
        "X-Mashape-Key" => "11shc2wgStmshV3bCl4iFyvaBZg4p1w5vXTjsnq3NYr4IrFN3z",
        "Accept" => "application/json"
      }
    break if response != nil 
    debug_int += 1
    p debug_int
  end
  response
end

def retrieve_sentence(word)
  core_sentences_set = File.readlines('data/core_data/manipulated_files/passages_cleaned.txt').map! do |sentence|
    sentence[0..-2]
  end
  selected_sentences_set = core_sentences_set.select! do |one_sentence|
      one_sentence.include?(word)
    end
  selected_sentences_set
end



