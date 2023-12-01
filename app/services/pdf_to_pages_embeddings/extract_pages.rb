class PdfToPagesEmbeddings::ExtractPages
  Page = Data.define(:number, :text, :token_count)

  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def call
    pdf_reader.pages.map.with_index do |page, index|
      Page.new(number: index + 1, text: page.text, token_count: count_tokens(page.text))
    end
  end

  private

  def count_tokens(text)
    tokenizer.encode(text).tokens.count
  end

  def tokenizer
    @tokenizer ||= Tokenizers.from_pretrained("gpt2")
  end

  def pdf_reader
    @pdf_reader ||= PDF::Reader.new(filename)
  end
end
