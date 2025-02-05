type entry = {msg: string}
type result = {
  checkpoints?: array<entry>,
  log?: string,
  error?: string,
}

@module("./react-trace.bc.js")
external run: (int, string) => result = "run"
