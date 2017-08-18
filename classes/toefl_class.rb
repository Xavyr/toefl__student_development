class ToeflQuestions
  attr_accessor :toefl_hash, :a_key

  def initialize
    question_set = create_question_set()

    @a_key = create_answer_hash()
    @toefl_hash = create_toefl_hash(question_set)
  end

  def create_question_set()
    all_words = File.read('data/toefl_questions/toefl_original_questions.txt').split("\n\n")
    question_set = all_words[0..-2]
    return question_set
  end

  def create_answer_hash()
    a_key = {}
    all_answers = File.readlines('data/toefl_questions/answer_key.txt')
    all_answers.each_with_index do |value, index|
      if index % 2 == 0
        a_key[value.to_i] = all_answers[index + 1].split("\n").pop
      end
    end
    a_key
  end

  def create_toefl_hash(set)
    hash = {}
    set.each do |question|
      key = question[0..2].to_i
      q_a_array = question[4..-1].split('?')
      the_q = q_a_array[0]
      the_answers = q_a_array[1]
      hash[key] = [the_q, the_answers]
    end
    hash
  end

  def generate_random_question
    # random_key = 115 for debugging purposes set random key to be real number
    #when want to call back same questions...feed a list of keys.
    random_key = @toefl_hash.keys.sample
    question = @toefl_hash[random_key][0]
    answers = @toefl_hash[random_key][1]
    correct = @a_key[random_key]
    [random_key, correct, question, answers]
  end

  def get_specific_question(key)
    key_int = key.to_i
    question = @toefl_hash[key_int][0]
    answers = @toefl_hash[key_int][1]
    correct = @a_key[key_int]
    [key_int, correct, question, answers]
  end



end



#####get the correct answer in there as apart of the set!!!
##side idea, pass in a word, try to get a question that has that word in it...



# (?<=^| )\d{3}(\.)


# question.match(/(?<=^| )\d{3}(\.)/)[0]

