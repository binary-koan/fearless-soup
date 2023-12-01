require 'csv'

class AnswerQuestion
  MODEL_NAME = "curie"
  QUERY_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-query-001"
  COMPLETIONS_MODEL = "text-davinci-003"
  COMPLETIONS_API_PARAMS = {
    # We use temperature of 0.0 because it gives the most predictable, factual answer.
    temperature: 0.0,
    max_tokens: 150,
    model: COMPLETIONS_MODEL
  }

  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* "

  COMMON_SECTIONS = {
    header: "Sahil Lavingia is the founder and CEO of Gumroad, and the author of the book The Minimalist Entrepreneur (also known as TME). These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful, pulled from The Minimalist Entrepreneur:\n",
    questions: [
      "\n\n\nQ: How to choose what business to start?\n\nA: First off don't be in a rush. Look around you, see what problems you or other people are facing, and solve one of these problems if you see some overlap with your passions or skills. Or, even if you don't see an overlap, imagine how you would solve that problem anyway. Start super, super small.",
      "\n\n\nQ: Q: Should we start the business on the side first or should we put full effort right from the start?\n\nA:   Always on the side. Things start small and get bigger from there, and I don't know if I would ever “fully” commit to something unless I had some semblance of customer traction. Like with this product I'm working on now!",
      "\n\n\nQ: Should we sell first than build or the other way around?\n\nA: I would recommend building first. Building will teach you a lot, and too many people use “sales” as an excuse to never learn essential skills like building. You can't sell a house you can't build!",
      "\n\n\nQ: Andrew Chen has a book on this so maybe touché, but how should founders think about the cold start problem? Businesses are hard to start, and even harder to sustain but the latter is somewhat defined and structured, whereas the former is the vast unknown. Not sure if it's worthy, but this is something I have personally struggled with\n\nA: Hey, this is about my book, not his! I would solve the problem from a single player perspective first. For example, Gumroad is useful to a creator looking to sell something even if no one is currently using the platform. Usage helps, but it's not necessary.",
      "\n\n\nQ: What is one business that you think is ripe for a minimalist Entrepreneur innovation that isn't currently being pursued by your community?\n\nA: I would move to a place outside of a big city and watch how broken, slow, and non-automated most things are. And of course the big categories like housing, transportation, toys, healthcare, supply chain, food, and more, are constantly being upturned. Go to an industry conference and it's all they talk about! Any industry…",
      "\n\n\nQ: How can you tell if your pricing is right? If you are leaving money on the table\n\nA: I would work backwards from the kind of success you want, how many customers you think you can reasonably get to within a few years, and then reverse engineer how much it should be priced to make that work.",
      "\n\n\nQ: Why is the name of your book 'the minimalist entrepreneur' \n\nA: I think more people should start businesses, and was hoping that making it feel more “minimal” would make it feel more achievable and lead more people to starting-the hardest step.",
      "\n\n\nQ: How long it takes to write TME\n\nA: About 500 hours over the course of a year or two, including book proposal and outline.",
      "\n\n\nQ: What is the best way to distribute surveys to test my product idea\n\nA: I use Google Forms and my email list / Twitter account. Works great and is 100% free.",
      "\n\n\nQ: How do you know, when to quit\n\nA: When I'm bored, no longer learning, not earning enough, getting physically unhealthy, etc… loads of reasons. I think the default should be to “quit” and work on something new. Few things are worth holding your attention for a long period of time."
    ]
  }

  attr_reader :text

  def initialize(text)
    @text = text
  end

  def call
    existing_question = Question.find_by(question: question_text)

    if existing_question
      existing_question.increment!(:ask_count)
      return existing_question
    end

    answer, context = answer_query_with_context

    Question.create!(question: question_text, answer: answer, context: context)
  end

  private

  def answer_query_with_context
    prompt, context = construct_prompt

    Rails.logger.info("Prompt: #{prompt}")

    response = client.completions(parameters: {
      prompt: prompt,
      **COMPLETIONS_API_PARAMS
    })

    [response["choices"][0]["text"].strip, context]
  end

  def construct_prompt
    chosen_sections = []
    chosen_sections_len = 0

    order_document_sections_by_query_similarity.each do |title|
      document_section = pages_by_title[title]

      chosen_sections_len += document_section["tokens"].to_i + SEPARATOR.length

      if chosen_sections_len > MAX_SECTION_LEN
        space_left = MAX_SECTION_LEN - chosen_sections_len - SEPARATOR.length
        chosen_sections << SEPARATOR + document_section["content"][0..space_left]
        break
      end

      chosen_sections << SEPARATOR + document_section["content"]
    end

    context = chosen_sections.join('')
    prompt = [
      COMMON_SECTIONS[:header],
      context,
      *COMMON_SECTIONS[:questions],
      "\n\n\nQ: #{question_text}\n\nA: "
    ].join('')

    [prompt, context]
  end

  # Find the query embedding for the supplied query, and compare it against all of the pre-calculated document embeddings
  # to find the most relevant sections.
  #
  # Return the list of document sections, sorted by relevance in descending order.
  def order_document_sections_by_query_similarity
    document_embeddings
      .sort_by { |_, embedding| vector_similarity(query_embedding, embedding) }
      .reverse
      .map { |title, _| title }
  end

  def vector_similarity(x, y)
    Vector[*x].inner_product(Vector[*y])
  end

  def query_embedding
    @query_embedding ||= client.embeddings(parameters: {
      model: QUERY_EMBEDDINGS_MODEL,
      input: question_text
    })['data'][0]['embedding']
  end

  def pages_by_title
    @pages_by_title ||= CSV.read('book.pdf.pages.csv', headers: :first_row).index_by { |row| row['title'] }
  end

  def document_embeddings
    @document_embeddings ||= CSV.read('book.pdf.embeddings.csv', headers: :first_row).to_h do |row|
      [row['title'], row.fields[1..-1].map(&:to_f)]
    end
  end

  def question_text
    text.end_with?('?') ? text : "#{text}?"
  end

  def client
    @client ||= OpenAI::Client.new
  end
end
