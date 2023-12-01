class PdfToPagesEmbeddings::ComputeEmbeddings
  MODEL_NAME = "curie"
  DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001"

  # On the free plan there's a rate limit of 3 RPM, so sleeping for 20 seconds is enough to fire the next request.
  # There's no easily parseable way to get this from the response though so hardcoding it here for now.
  RATE_LIMIT_SLEEP_TIME = 20

  attr_reader :text

  def initialize(text)
    @text = text
  end

  def call
    perform_request
  rescue Faraday::TooManyRequestsError
    Rails.logger.info("Too many requests, sleeping for #{RATE_LIMIT_SLEEP_TIME} seconds ...")
    sleep RATE_LIMIT_SLEEP_TIME
    perform_request
  end

  private

  def perform_request
    result = client.embeddings(
      parameters: {
        model: DOC_EMBEDDINGS_MODEL,
        input: text
      }
    )

    result.dig("data", 0, "embedding")
  end

  def client
    @client ||= OpenAI::Client.new
  end
end
