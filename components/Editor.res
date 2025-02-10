@@directive("'use client';")

let sample = `
let C x =
  let (s, setS) = useState x in
  if s = 42 then
    setS (fun s -> s + 1);
  view [s]
;;
let D _ =
  let (s, setS) = useState true in
  useEffect (setS (fun _ -> false));
  view [C 42, if s then 1 else 0]
;;
view [D (), ()]
`->String.trim

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
        let y = height /. 10.
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

@react.component
let make = () => {
  let fuel = 0 // 0 means unlimited fuel
  let (code, setCode) = React.useState(() => sample)
  let (recording, setRecording) = React.useState(() => ReacttRace.run(fuel, code))

  let (currentStep, setCurrentStep) = React.useState(() => 0)
  let (report, treeData, steps) = switch recording {
  | {checkpoints} => {
      open ReacttRace
      (
        checkpoints
        ->Array.map(x => x.msg)
        ->Array.slice(~start=0, ~end=currentStep)
        ->Array.join("\n"),
        if currentStep == 0 {
          ({}: ReactD3Tree.data)
        } else {
          /* Field names are shared, so we can use the same record type */
          (checkpoints->Array.getUnsafe(currentStep - 1)).tree->Obj.magic
        },
        checkpoints->Array.length,
      )
    }
  | {error} => (error, {}, 0)
  | _ => assert(false)
  }

  let onChange = value => {
    setCode(_ => value)
    setCurrentStep(_ => steps)
    setRecording(_ => ReacttRace.run(fuel, value))
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
    <div className="flex flex-col lg:flex-row gap-2">
      <ReactCodeMirror
        value=code onChange extensions className="w-full lg:w-1/2 text-base font-mono"
      />
      <div
        className="w-full lg:w-1/2 h-[500px] rounded-lg resize-y overflow-hidden border"
        ref=containerRef>
        <ReactD3Tree data=treeData translate orientation="vertical" />
      </div>
    </div>
    <Slider
      value=[currentStep]
      onValueChange={vs => setCurrentStep(_ => vs->Array.getUnsafe(0))}
      step=1
      max=steps
    />
    <div className="text-base font-sans text-gray-800 whitespace-pre-wrap">
      {report->React.string}
    </div>
  </div>
}
