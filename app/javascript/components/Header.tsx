import { FC } from "react"
import bookImage from "../assets/book.png"

const Header: FC = () => {
  return (
    <div className="header">
      <div className="logo">
        <a href="https://www.amazon.com/Minimalist-Entrepreneur-Great-Founders-More/dp/0593192397">
          <img src={bookImage} loading="lazy" />
        </a>
        <h1>Ask My Book</h1>
      </div>
    </div>
  )
}

export default Header
