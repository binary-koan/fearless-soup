RSpec.describe AnswerQuestion do
  let(:text) { "test question?" }

  let(:client) { instance_double(OpenAI::Client) }

  subject(:service) { AnswerQuestion.new(text) }

  context "when no matching question exists" do
    before do
      expect(OpenAI::Client).to receive(:new).and_return(client)

      expect(client).to receive(:embeddings).with({
        parameters: {
          model: described_class::QUERY_EMBEDDINGS_MODEL,
          input: a_string_including(text)
        }
      }).and_return({
        "data" => [{
          "embedding" => (0...4096).to_a
        }]
      })

      expect(client).to receive(:completions).with({
        parameters: a_hash_including(prompt: a_string_including(text))
      }).and_return({
        "choices" => [{
          "text" => "test answer"
        }]
      })
    end

    it "creates a question" do
      expect { service.call }.to change { Question.count }.by(1)
    end

    it "returns the created question" do
      question = service.call

      expect(question.question).to eq text
      expect(question.answer).to eq "test answer"
      expect(question.context).to be_a String
      expect(question.ask_count).to eq 1
    end

    context "when the prompt does not end with a question mark" do
      let(:text) { "test question" }

      it "appends a question mark to the prompt" do
        expect(service.call.question).to end_with("?")
      end
    end
  end

  context "when a matching question already exists" do
    let!(:question) { Question.create!(question: text, answer: "test answer", context: "test context") }

    it "returns the matching question" do
      expect(service.call).to eq question
    end

    it "does not create a new question" do
      expect { service.call }.not_to change { Question.count }
    end

    it "increments ask count" do
      expect { service.call }.to change { question.reload.ask_count }.by(1)
    end

    context "when the prompt does not end with a question mark" do
      let(:text) { "test question" }

      let!(:question) { Question.create!(question: "test question?", answer: "test answer", context: "test context") }

      it "checks existing after adding a question mark" do
        expect(service.call).to eq question
      end
    end
  end
end
