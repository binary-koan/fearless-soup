import { FC, useState } from "react"
import AnswerDisplay from "./AnswerDisplay"
import Footer from "./Footer"
import Header from "./Header"
import QuestionForm from "./QuestionForm"

const App: FC = () => {
  const [answer, setAnswer] = useState<string | null>(null)

  return (
    <>
      <Header />

      <div className="main">
        <QuestionForm hideButtons={!!answer} onAnswer={setAnswer} />
        <AnswerDisplay answer={answer} onReset={() => setAnswer(null)} />
      </div>

      <Footer />
    </>
  )
}

export default App
