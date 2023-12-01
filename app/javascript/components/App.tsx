import { FC, useState } from "react"
import AnswerDisplay from "./AnswerDisplay"
import Footer from "./Footer"
import Header from "./Header"
import QuestionForm, { QuestionResponse } from "./QuestionForm"

const App: FC<{ initialResponse?: QuestionResponse }> = ({ initialResponse }) => {
  const [response, setResponse] = useState<QuestionResponse | undefined>(initialResponse)

  const reset = () => setResponse(undefined)

  const updatePath = () => {
    // This feels a bit awkward. Thought I might as well replicate the original behaviour precisely,
    // but IMO it would be nicer to just update the URL as soon as the request is complete
    if (response) {
      window.history.pushState({}, "", `/question/${response.id}`)
    }
  }

  return (
    <>
      <Header />

      <div className="main">
        <QuestionForm
          initialValue={initialResponse?.question}
          hideButtons={!!response}
          onResponse={setResponse}
          onInput={reset}
        />
        <AnswerDisplay answer={response?.answer} onFullyDisplayed={updatePath} onReset={reset} />
      </div>

      <Footer />
    </>
  )
}

export default App
