@module("@uiw/react-codemirror") @react.component
external make: (
  ~value: string,
  ~mode: string=?,
  ~height: string=?,
  ~onChange: string => unit=?,
  ~extensions: array<'extension>=?,
) => React.element = "default"
