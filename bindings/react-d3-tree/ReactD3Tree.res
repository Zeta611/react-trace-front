@module("react-d3-tree") @react.component
external make: (
  ~data: Js.Json.t,
  ~translate: (float, float)=?,
  ~orientation: string=?,
  ~pathFunc: string=?,
  unit,
) => React.element = "default"
