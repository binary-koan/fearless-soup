import { FC, useEffect, useRef, useState } from "react"
import { randomInteger } from "../utils/randomInteger"
import { sleep } from "../utils/sleep"

const AnswerDisplay: FC<{
  answer?: string
  onFullyDisplayed: () => void
  onReset: () => void
}> = ({ answer, onFullyDisplayed, onReset }) => {
  const isInitialAnswer = useRef(true)
  const [displayedAnswer, setDisplayedAnswer] = useState("")

  useEffect(() => {
    if (!answer) {
      return
    }

    const controller = new AbortController()

    const typeText = async () => {
      let current = ""

      while (current.length < answer.length && !controller.signal.aborted) {
        current += answer[current.length]
        setDisplayedAnswer(current)

        await sleep(randomInteger(30, 70))
      }

      onFullyDisplayed()
    }

    if (isInitialAnswer.current) {
      setDisplayedAnswer(answer)
    } else {
      typeText()
    }

    return () => controller.abort()
  }, [answer])

  useEffect(() => {
    isInitialAnswer.current = false
  }, [])

  const finishedTyping = displayedAnswer === answer

  return (
    <p id="answer-container" className={answer ? "" : "hidden"}>
      <strong>Answer: </strong>
      {displayedAnswer}
      <button style={{ display: finishedTyping ? "block" : "none" }} onClick={onReset}>
        Ask another question
      </button>
    </p>
  )
}

export default AnswerDisplay
