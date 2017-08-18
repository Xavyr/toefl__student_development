all_words = File.read('toefl_original_questions.txt').split("\n\n")
question_set = all_words[0..-2]
question_set