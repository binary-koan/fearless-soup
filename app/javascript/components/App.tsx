import { useState } from "react"

const csrfToken = document.querySelector<HTMLMetaElement>("meta[name=csrf-token]")!.content

const App: React.FC = () => {
  const [question, setQuestion] = useState("")
  const [answer, setAnswer] = useState<string | null>(null)

  const fetchAnswer = async () => {
    const response = await fetch(`/ask?question=${question}`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken
      }
    })
    const data = await response.json()
    setAnswer(data.answer)
  }

  return (
    <>
      <input
        type="text"
        placeholder="Question"
        value={question}
        onChange={(e) => setQuestion(e.target.value)}
      />
      <button onClick={fetchAnswer}>Answer</button>

      {answer && <p>{answer}</p>}
    </>
  )
}

export default App
