import { ChangeEvent, FC, useState } from "react"
import { randomInteger } from "../utils/randomInteger"

export interface QuestionResponse {
  id: number
  question: string
  answer: string
}

const csrfToken = document.querySelector<HTMLMetaElement>("meta[name=csrf-token]")!.content

const QuestionForm: FC<{
  initialValue?: string
  onInput: () => void
  onResponse: (response: QuestionResponse) => void
  hideButtons: boolean
}> = ({ initialValue, onInput, onResponse, hideButtons }) => {
  const [question, setQuestion] = useState(
    initialValue || "What is The Minimalist Entrepreneur about?"
  )
  const [isLoading, setLoading] = useState(false)

  const onChange = (e: ChangeEvent<HTMLTextAreaElement>) => {
    setQuestion(e.target.value)
    onInput()
  }

  const onAsk = async (question: string) => {
    setLoading(true)

    try {
      const response = await fetch(`/ask?question=${question}`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken
        }
      })
      onResponse(await response.json())
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
      <textarea name="question" value={question} onChange={onChange} />

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
