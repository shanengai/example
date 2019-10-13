# Name: Shane Ngai, Collaborator: Amr Abdelhady
# Version: Ruby 2.5.1

class MarkovChainTextGenerator
  # Implements a trigram markov chain text generator given some input file.
  include Enumerable

  def initialize(input_file)
    # Creates a markov chain based on the input file using a hash.
    # CITE: https://stackoverflow.com/questions/5011504/is-there-a-way-to-
    #       remove-the-bom-from-a-utf-8-encoded-file#7780531
    # DESC: Used to address BOM marker when creating the markov chain.
    @words = File.read(input_file, :encoding => 'bom|utf-8').split(" ")
    @chain = {}
    @file = input_file
    @generated_sentence = ""

    # Store every two words as a key and sets each key's value to an array.
    for i in 0..@words.length - 2
      if not @chain[@words[i] + " " + @words[i + 1]]
        @chain[@words[i] + " " + @words[i + 1]] = []
      end
    end

    # Fills each key's array with potential follow-up choices.
    # This will take O(n^2) time to store, which may increase the
    # amount of time it takes to load a file.
    for key in @chain.keys
      for i in 0..@chain.keys.length - 1
        if key.split(" ")[1] == @chain.keys[i].split(" ")[0]
          @chain[key] << @chain.keys[i]
        end
      end
    end
  end

  def to_s
    # Prints a string to describe the object.
    puts "Markov Chain Text Generator of file: #{@file}."
  end

  def inspect
    # Prints a string to describe the object.
    to_s
  end

  def generate_text(text_length)
    # Randomly generates text of size: text_length.
    # Handles cases where the text_length may be less than 0 or equal to one.
    return "" if @words.length == 0 or text_length == 0
    return @chain.sample.split(" ").sample if text_length == 1

    # Handles the case where the length of the input file is equal to one.
    return ((@words[0] + " ") * text_length)[0..-2] if @words.length == 1

    # Handles the case where the length of the input file is equal to two.
    seed = @chain.keys[0].split(" ").sample + " "
    return (seed * text_length)[0..-2] if @words.length == 2

    seed = @chain.keys.sample
    text = ""

    # Generates a string of random text of text_length words.
    for i in 0..text_length - 1
      seed = @chain[seed] == [] ? @chain.keys.sample : @chain[seed].sample 
      text += seed.split(" ")[1] + " "
    end
    return text[0, text.length - 1].to_s  # Used to delete the last " ".
  end

  def generate_sentence
    # Randomly generates a properly formatted sentence. This does not account
    # for matching quotation marks.
    error = "This text file does not allow a valid sentence to be generated."

    # Stores all of the possible starting keys as an array.
    start = []
    for key in @chain.keys
      if key[0] == "\"" and key[1] == key[1].upcase
        start << key
      end
      if key[0] == key[0].upcase and key[1] != "\""
        start << key
      end
    end

    # Handles the case where there are no starting keys.
    return error if start == []

    seed = start.sample
    text = seed + " "

    # Handles the case where the first word of a seed is a sentence.
    if seed.include?(".") or seed.include?("?") or seed.include?("!")
      return seed.split(" ")[0]  # Has to be the first element due to start.
    end

    # Generates a random sentence after the start seed.
    for i in 0..@words.length - 1
      # Handles the case where there are no ending sentence indicators.
      return error if i + 1 == @words.length
      # Leaves the loop if there 
      break if text.include?(".") | text.include?("?") | text.include?("!")
      seed = @chain[seed] == [] ? @chain.keys.sample : @chain[seed].sample 
      text += seed.split(" ")[1] + " "
    end
    @generated_sentence = text[0, text.length - 1]  # Used for each method.
    return text[0, text.length - 1].to_s  # Used to delete the last " ".
  end

  def each
    # Yields each word in a randomly generated sentence.
    generate_sentence  # This call sets the value for @generated_sentence.
    @generated_sentence.split(" ").each{ |w| yield w }
    return @generated_sentence
  end
end