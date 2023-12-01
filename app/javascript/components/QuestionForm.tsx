import { FC, useState } from "react"
import { randomInteger } from "../utils/randomInteger"

const csrfToken = document.querySelector<HTMLMetaElement>("meta[name=csrf-token]")!.content

const QuestionForm: FC<{ onAnswer: (answer: string) => void; hideButtons: boolean }> = ({
  onAnswer,
  hideButtons
}) => {
  const [question, setQuestion] = useState("What is The Minimalist Entrepreneur about?")
  const [isLoading, setLoading] = useState(false)

  const onAsk = async (question: string) => {
    setLoading(true)

    try {
      const response = await fetch(`/ask?question=${question}`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken
        }
      })
      const data = await response.json()
      onAnswer(data.answer)
    } catch (e) {
      console.error(e)
      alert("Something went wrong!")
    } finally {
      setLoading(false)
    }
  }

  const onSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    onAsk(question)
  }

  const onLucky = () => {
    const options = [
      "What is a minimalist entrepreneur?",
      "What is your definition of community?",
      "How do I decide what kind of business I should start?"
    ]
    const selection = options[randomInteger(0, options.length - 1)]

    setQuestion(selection)
    onAsk(selection)
  }

  return (
    <form onSubmit={onSubmit}>
      <textarea name="question" value={question} onChange={(e) => setQuestion(e.target.value)} />

      <div className="buttons" style={{ display: hideButtons ? "none" : undefined }}>
        <button type="submit" disabled={isLoading}>
          {isLoading ? "Asking ..." : "Ask question"}
        </button>

        <button type="button" disabled={isLoading} className="lucky" onClick={onLucky}>
          I'm feeling lucky
        </button>
      </div>
    </form>
  )
}

export default QuestionForm
