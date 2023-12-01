require 'csv'

class ConvertPdfToPagesEmbeddings
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def call
    File.write("book.pdf.pages.csv", pages_csv)
    File.write("book.pdf.embeddings.csv", embeddings_csv)
  end

  private

  def pages_csv
    Rails.logger.info("Extracting pages from PDF")
    CSV.generate do |csv|
      csv << ["title", "content", "tokens"]

      pages.each do |page|
        csv << [page.title, page.text.squish, page.token_count]
      end
    end
  end

  def embeddings_csv
    CSV.generate do |csv|
      csv << ["title", *0...4096]

      pages.each do |page|
        Rails.logger.info("Computing embeddings for #{page.title}")
        csv << [page.title, *PdfToPagesEmbeddings::ComputeEmbeddings.new(page.text).call]
      end
    end
  end

  def pages
    @pages ||= PdfToPagesEmbeddings::ExtractPages.new(filename).call
  end
end
