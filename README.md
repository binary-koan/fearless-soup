# README

A clone of https://github.com/slavingia/askmybook in Rails and React.

## Running the app

1. Copy `.env.example` to `.env` and add your OpenAI API key
2. Run `bundle install` and `bin/rails db:migrate`
3. Copy the book PDF you want to use to the root directory
4. Run `bin/pdf-to-pages-embeddings book.pdf` and wait for it to complete

Now you can run the project with `bin/rails server`

You can also run tests with `bundle exec rspec`. I added a few test cases just to demonstrate how I would go about writing them, but a lot of this is fairly awkward to test (relying a lot on APIs and the file system) so I didn't go too deep into it.

## Notes

I've decided to keep the React components in the Rails project and write them in TypeScript via [react-rails](https://github.com/reactjs/react-rails/tree/master) and [Shakapacker](https://github.com/shakacode/shakapacker). I haven't set up React in Rails for a little while so I had a look at a few ways to do it, and this was the only integrated way that supports TypeScript.

It was a bit awkward getting Shakapacker working nicely and removing Sprockets, so in hindsight it might have been simpler just to use plain JS for a simple app like this. I also considered making an entirely separate frontend app (e.g. with Vite or Next.js) and using Rails purely as an API - this would reduce the moving parts on the Rails side of things and be more scalable for a larger project, but I think it would be overkill for something like this.

In general I've tried to just keep things simple on the frontend - this isn't a complex enough UI to be worth using contexts/routers/state management libraries/etc.

For business logic I used a very simple service/use-case pattern (see `app/services`). This keeps the model and controller layers nice and thin, making the code simpler to follow and easier to test - even in a simple project like this I think having smaller, more encapsulated pieces of logic makes it easier to figure out what's going on. I've seen various patterns and libraries for service objects, but just using POROs in a single `services` directory seemed most appropriate here to avoid overcomplicating things.

I deliberately kept the logic almost identical to the original project, including keeping the same CSV file format. This was helpful because I could regression test against the original project (for example checking that my vector similarity sorting was working the same), but it's not a particularly Rails-y solution. It might be more conventional to do something like generating YAML and storing it in `config`, but I think although that would "feel" nicer there's not much practical value so it's not worth the extra time and effort here.

I noticed the original project also has an admin panel and db page, but rebuilding those aren't in the requirements. So I added a quick react-admin page to demonstrate how I might go about building one, but didn't spend too much extra time making it fully functional, adding authentication, etc.

I also didn't add much error handling or abuse prevention since the original project doesn't have it. Before making this too public I'd want to do things like handle API errors, impose rate limits, etc.
