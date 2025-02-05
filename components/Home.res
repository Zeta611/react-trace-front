@@directive("'use client';")

@val external process: 'process = "process"

let lazyEditor = Next.Dynamic.dynamic(
  async () => await import(Editor.make),
  {
    ssr: process["env"]["NODE_ENV"] == "development",
    loading: () => <Loading />,
  },
)

@react.component
let make = () => {
  let editor = React.createElement(lazyEditor, {})

  <main className="flex flex-col gap-4">
    <h1 className="text-4xl font-serif"> {"React-tRace"->React.string} </h1>
    editor
  </main>
}
