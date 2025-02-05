type translation = {
  x: float,
  y: float,
}

@module("react-d3-tree") @react.component
external make: (
  ~data: Js.Json.t,
  ~translate: translation=?,
  ~orientation: string=?,
  ~pathFunc: string=?,
  unit,
) => React.element = "default"
