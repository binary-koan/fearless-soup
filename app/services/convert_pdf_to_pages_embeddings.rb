require 'csv'

class ConvertPdfToPagesEmbeddings
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def call
    File.write("book.pdf.pages.csv", pages_csv)
  end

  private

  def pages_csv
    CSV.generate do |csv|
      csv << ["title", "content", "tokens"]

      pages.each do |page|
        csv << ["Page #{page.number}", page.text, page.token_count]
      end
    end
  end

  def pages
    @pages ||= PdfToPagesEmbeddings::ExtractPages.new(filename).call
  end

  def client
    @client ||= OpenAI::Client.new
  end
end
