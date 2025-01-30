type sliderProps = {
  ...JsxDOM.domProps,
}

@module("./slider") @react.component(: sliderProps)
external make: unit => React.element = "Slider"
