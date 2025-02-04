@@directive("'use client';")

@react.component
let make = () => {
  let lazyEditor = Next.Dynamic.dynamic(
    async () => await import(Editor.make),
    {
      ssr: false,
      loading: () => <span> {"Loading..."->React.string} </span>,
    },
  )
  let editor = React.createElement(lazyEditor, {})

  <main className="flex flex-col gap-4">
    <h1 className="text-4xl font-serif"> {"React-tRace"->React.string} </h1>
    editor
  </main>
}
