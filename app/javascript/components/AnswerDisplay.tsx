import { FC } from "react"

const AnswerDisplay: FC<{ answer: string | null; onReset: () => void }> = ({ answer, onReset }) => {
  return (
    <p id="answer-container" className={answer ? "" : "hidden"}>
      <strong>Answer: </strong>
      {answer}
      <button style={{ display: "block" }} onClick={onReset}>
        Ask another question
      </button>
    </p>
  )
}

export default AnswerDisplay
