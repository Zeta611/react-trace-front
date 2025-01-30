type result = {
  checkpoints?: array<string>,
  log?: string,
  error?: string,
}

@module("./react-trace.bc.js")
external run: (int, string) => result = "run"
