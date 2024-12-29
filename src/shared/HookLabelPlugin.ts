import {
  Decoration,
  DecorationSet,
  EditorView,
  ViewPlugin,
  ViewUpdate,
  WidgetType,
} from "@codemirror/view";
import { syntaxTree } from "@codemirror/language";

class HookLabelWidget extends WidgetType {
  constructor(readonly label: number) {
    super();
  }

  eq(other: HookLabelWidget) {
    return other.label == this.label;
  }

  toDOM() {
    const elem = document.createElement("sup");
    elem.textContent = `${this.label}`;
    return elem;
  }
}

function hookLabels(view: EditorView) {
  const widgets = [];
  let cnt = 0;
  for (const { from, to } of view.visibleRanges) {
    syntaxTree(view.state).iterate({
      from,
      to,
      enter: (node) => {
        if (view.state.doc.sliceString(node.from, node.to) == "useState") {
          const deco = Decoration.widget({
            widget: new HookLabelWidget(cnt++),
            side: 1,
          });
          widgets.push(deco.range(node.to));
        }
      },
    });
  }
  return Decoration.set(widgets);
}

const hookLabelPlugin = ViewPlugin.fromClass(
  class {
    decorations: DecorationSet;

    constructor(view: EditorView) {
      this.decorations = hookLabels(view);
    }

    update(update: ViewUpdate) {
      if (
        update.docChanged ||
        update.viewportChanged ||
        syntaxTree(update.startState) != syntaxTree(update.state)
      ) {
        this.decorations = hookLabels(update.view);
      }
    }
  },
  {
    decorations: (v) => v.decorations,
  },
);

export { hookLabelPlugin as plugin };
