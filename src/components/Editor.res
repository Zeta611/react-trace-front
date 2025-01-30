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
let vim = CodeMirrorVim.vim()

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

  let (jsMode, setJSMode) = React.useState(() => false)
  let (vimMode, setVimMode) = React.useState(() => false)
  let extensions = []->Array.concatMany([
    // vim extension should be the first one
    if vimMode {
      [vim]
    } else {
      []
    },
    if jsMode {
      [javascript]
    } else {
      [coreLang]
    },
    [CodeMirrorThemeTokyoNightDay.tokyoNightDay, HookLabelPlugin.plugin],
  ])

  <div className="flex flex-col gap-4">
    <div className="flex place-self-end items-center space-x-4 text-sm font-medium">
      <div className="flex space-x-2">
        <Checkbox
          id="check-vim-mode" checked=vimMode onCheckedChange={checked => setVimMode(_ => checked)}
        />
        <label
          htmlFor="check-vim-mode"
          className="leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
          {"Vim Keymap"->React.string}
        </label>
      </div>
      <div className="flex space-x-2">
        <Checkbox
          id="check-js-mode" checked=jsMode onCheckedChange={checked => setJSMode(_ => checked)}
        />
        <label
          htmlFor="check-js-mode"
          className="leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
          {"JS Syntax"->React.string}
        </label>
      </div>
    </div>
    <ReactCodeMirror value onChange extensions className="text-base font-mono" />
    <div className="text-lg font-sans text-gray-800 whitespace-pre-wrap">
      {recording->Option.getOr("Loading...")->React.string}
    </div>
  </div>
}
