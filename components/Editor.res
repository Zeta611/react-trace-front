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

let treeData = Js.Json.parseExn(`
  [
    {
      "name": "Root",
      "children": [
        { "name": "Child 1" },
        { "name": "Child 2", "children": [{ "name": "Grandchild" }] }
      ]
    }
  ]
`)

let useCenteredTree = () => {
  open ReactD3Tree
  let (translate, setTranslate) = React.useState(() => {x: 0., y: 0.})
  let containerRef = ReactDOM.Ref.callbackDomRef(container => {
    switch container {
    | Value(container) => {
        open Webapi.Dom
        let rect = container->Element.getBoundingClientRect
        let width = rect->DomRect.width
        let height = rect->DomRect.height
        let x = width /. 2.
        let y = height /. 6.
        if translate.x !== x || translate.y !== y {
          setTranslate(_ => {x, y})
        }
      }
    | _ => ()
    }
  })
  (translate, containerRef)
}

let javascript = LangJavaScript.javascript()
let vim = CodeMirrorVim.vim()

@module("../shared/syntax/language.js")
external core: 'lang = "core"
let coreLang = core()

let reacttRace = (fuel, value) => {
  try {
    ReacttRace.run(fuel, value)
  } catch {
  | Exn.Error(e) => {
      Console.error(e)
      {ReacttRace.error: "Runtime error"}
    }
  }
}

@react.component
let make = () => {
  let fuel = 0 // 0 means unlimited fuel
  let (code, setCode) = React.useState(() => sample)
  let (recording, setRecording) = React.useState(() => reacttRace(fuel, code))

  let (currentStep, setCurrentStep) = React.useState(() => 0)
  let (report, steps) = switch recording {
  | {checkpoints} => (
      checkpoints
      ->Array.slice(~start=0, ~end=currentStep)
      ->Array.map(x => x.ReacttRace.msg)
      ->Array.join("\n"),
      checkpoints->Array.length,
    )
  | {error} => (error, 0)
  | _ => assert(false)
  }

  let onChange = value => {
    setCode(_ => value)
    setCurrentStep(_ => steps)
    setRecording(_ => reacttRace(fuel, value))
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

  let (translate, containerRef) = useCenteredTree()

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
    <ReactCodeMirror value=code onChange extensions className="text-base font-mono" />
    <Slider
      value=[currentStep]
      onValueChange={vs => setCurrentStep(_ => vs->Array.getUnsafe(0))}
      step=1
      max=steps
    />
    <div className="w-full h-96 rounded-lg resize-y overflow-hidden border" ref=containerRef>
      <ReactD3Tree data=treeData translate orientation="vertical" />
    </div>
    <div className="text-lg font-sans text-gray-800 whitespace-pre-wrap">
      {report->React.string}
    </div>
  </div>
}
