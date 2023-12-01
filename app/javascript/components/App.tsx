import { FC, useState } from "react"
import AnswerDisplay from "./AnswerDisplay"
import Footer from "./Footer"
import Header from "./Header"
import QuestionForm from "./QuestionForm"

const App: FC = () => {
  const [answer, setAnswer] = useState<string | null>(null)

  const reset = () => setAnswer(null)

  return (
    <>
      <Header />

      <div className="main">
        <QuestionForm hideButtons={!!answer} onAnswer={setAnswer} onInput={reset} />
        <AnswerDisplay answer={answer} onReset={reset} />
      </div>

      <Footer />
    </>
  )
}

export default App
