class Word
  attr_accessor :word, :result

  def initialize(a_word, a_result)
    @word = a_word
    @result = a_result
  end

  def definition
    @result["definition"]
  end

  def synonyms
    @result["synonyms"]
  end

  def examples
    @result["examples"]
  end

  def similar_to
    @result["similarTo"]
  end

end