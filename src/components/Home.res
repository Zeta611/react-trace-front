@react.component
let make = async () => {
  <main className="flex flex-col gap-4">
    <h1 className="text-3xl"> {"React-tRace"->React.string} </h1>
    <Editor />
  </main>
}
