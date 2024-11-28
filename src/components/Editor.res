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

@react.component
let make = () => {
  let (value, setValue) = React.useState(() => sample)
  let onChange = value => {
    Console.log(value)
    setValue(_ => value)
  }

  <div className="flex flex-col gap-4">
    <ReactCodeMirror
      value
      mode="ocaml"
      height="300px"
      onChange
      extensions=[CodeMirrorThemeTokyoNightDay.tokyoNightDay, javascript]
    />
    {"React-tRace"->React.string}
  </div>
}
