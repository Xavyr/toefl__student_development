all_words = File.readlines('manipulated_files/core_words_found_in_passages.txt').map! do |word|
              word[0..-2]
            end

occurences = {}

text = File.readlines('manipulated_files/passages_cleaned.txt').map! do |word|
             word[0..-2].downcase!
           end

string_words = text.join(' ').split(' ')

all_words.each do |word|
  count = 0
  string_words.each do |test|
    if test.include?(word) || test == word
      count += 1
    end
  end
  occurences[word] = count
end


answer = occurences.sort_by { |word, num| num }.reverse!.to_h

p answer


# passage_words = File.read('passages_cleaned.txt').downcase!.gsub!(/[.,]/, '').split(' ')

# sentences = []



# sentences.each do |sentence|
#   open('final_text.txt', 'a') { |f|
#     f.puts (sentence)
#   }
# end

#go check final_text for the sentences


