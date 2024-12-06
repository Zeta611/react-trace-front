@react.component
let make = async () => {
  <main className="flex flex-col gap-4">
    <h1 className="text-4xl font-serif"> {"React-tRace"->React.string} </h1>
    <Editor />
  </main>
}
