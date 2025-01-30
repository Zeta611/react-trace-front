@@directive("'use client';")

let sample = `
let C x =
  let (s, setS) = useState x in
  if s = 42 then
    setS (fun s -> s + 1);
  view [()]
;;
let D _ =
  let (s, setS) = useState true in
  useEffect (setS (fun _ -> false));
  view [C 42]
;;
view [D (), 0]
`->String.trim

let javascript = LangJavaScript.javascript()

@module("../shared/syntax/language.js")
external core: 'lang = "core"
let coreLang = core()

let fetchedReacttRace: ref<option<(int, string) => string>> = ref(None)

let reacttRace = {
  let handleExn = run => (fuel, value) => {
    try {
      run(fuel, value)
    } catch {
    | Exn.Error(e) => {
        Console.error(e)
        "Runtime error"
      }
    }
  }

  (fuel, value, setRecording) => {
    switch fetchedReacttRace.contents {
    | Some(run) => setRecording(_ => Some(run(fuel, value)))
    | None =>
      (
        async () => {
          let run = handleExn(await ReacttRaceWrapper.fetch())
          fetchedReacttRace := Some(run)
          setRecording(_ => Some(run(fuel, value)))
        }
      )()->ignore
    }
  }
}

type mode = Core | JS

@react.component
let make = () => {
  let fuel = 0 // 0 means unlimited fuel
  let (value, setValue) = React.useState(() => sample)
  let (recording, setRecording) = React.useState(() =>
    fetchedReacttRace.contents->Option.map(run => run(fuel, value))
  )

  React.useEffect(() => {
    if recording->Option.isNone {
      // ReacttRace has not been fetched yet
      reacttRace(fuel, value, setRecording)
    }
    None
  }, [])

  let onChange = value => {
    setValue(_ => value)
    reacttRace(fuel, value, setRecording)
  }

  let (mode, setMode) = React.useState(() => Core)
  let extensions = [CodeMirrorThemeTokyoNightDay.tokyoNightDay, HookLabelPlugin.plugin]
  switch mode {
  | Core => extensions->Array.push(coreLang)
  | JS => extensions->Array.push(javascript)
  }

  <div className="flex flex-col gap-4">
    <div className="flex place-self-end items-center space-x-2">
      <Checkbox
        id="check-js-mode"
        checked={mode == JS}
        onCheckedChange={checked => setMode(_ => checked ? JS : Core)}
      />
      <label
        htmlFor="check-js-mode"
        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
        {"JS Syntax"->React.string}
      </label>
    </div>
    <ReactCodeMirror value onChange extensions className="text-base font-mono" />
    <div className="text-lg font-sans text-gray-800 whitespace-pre-wrap">
      {recording->Option.getOr("Loading...")->React.string}
    </div>
  </div>
}
