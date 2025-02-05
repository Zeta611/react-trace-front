@@directive("'use client';")

let lazyEditor = Next.Dynamic.dynamic(
  async () => await import(Editor.make),
  {
    ssr: %raw("process.env.NODE_ENV === 'development'"),
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
