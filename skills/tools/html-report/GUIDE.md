# HTML Report Guide

The scaffold, the diagram choices, and the styling. The rules about what belongs in a report at all
live in [SKILL.md](SKILL.md).

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Report for {{subject}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* a small custom layer for what Tailwind does not cover cleanly:
         dashed lines, emphasis strokes, dark surfaces. */
      .dashed { stroke-dasharray: 4 4; }
      .alert { stroke: #dc2626; }
      .dark-surface { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="summary">...</section>
      <section id="cards" class="space-y-10">...</section>
      <section id="recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

What was examined, the date, and the scope in one line. A compact legend if the diagrams use marks
that need one. No introduction paragraph; go straight to the summary.

## The card

Each item is one `<article>` with the same fields in the same order:

- **Title**: short, and it names the change.
- **Badge row**: a strength (`Strong`, `Worth exploring`, `Speculative`) in emerald, amber, or
  slate, plus one tag for the kind of item.
- **Where**: the files involved, `font-mono text-sm`.
- **Before / After**: the centrepiece. Two columns, side by side. See the patterns below.
- **Problem**: one sentence. What hurts.
- **Solution**: one sentence. What changes.
- **Wins**: bullets, six words or fewer each.
- **Caveat callout** (when one applies): one line in an amber-tinted box, beside the item it applies
  to.

No paragraphs of explanation. If a diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the item. Mix them; every diagram looking the same is itself a defect.

### Mermaid graph

For "X calls Y calls Z, and look at the mess". Wrap it in a card so it does not feel parachuted in.
Use `classDef` to mark the edge or node that matters. Sequence diagrams work for "before: six
round-trips; after: one".

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[Entry] --> B[Validate]
      B --> C[Store]
      C -.leak.-> D[Remote call]
      classDef alert stroke:#dc2626,stroke-width:2px;
      class C,D alert
  </pre>
</div>
```

### Hand-built boxes and arrows

Modules as bordered `<div>`s; arrows as absolutely positioned inline SVG `<line>` or `<path>`. Use
this when Mermaid's layout fights the point you are making — for example when the "after" state has
to read as one thick-bordered block with greyed-out internals.

### Cross-section

Stack horizontal bands (`h-12 border-l-4`) to show the layers a call passes through. Before: six
thin layers doing nothing. After: one thick band carrying the consolidated responsibility.

### Mass diagram

Two rectangles per item: one for surface area, one for what sits behind it. Before: surface nearly as
tall as the body. After: short surface, tall body.

### Collapse

Before: a tree of boxes. After: the same tree collapsed into one box, with the now-internal parts
faded inside it.

## Style

- Editorial, not dashboard. Generous whitespace. A serif heading (`font-serif`) pairs well with
  stone and slate.
- Colour sparingly: one accent, plus red for the thing that is wrong and amber for the thing that
  needs care.
- Keep diagrams around 320px tall so a before/after pair sits side by side without scrolling.
- `text-xs uppercase tracking-wider` for diagram labels reads as schematic rather than as UI.
- The only scripts are the Tailwind CDN and the Mermaid import. Everything else is static.

## Accessibility

- Semantic landmarks: `header`, `main`, `section`, `article`.
- Text contrast at 4.5:1 or better, including inside diagrams.
- No information carried by colour alone: pair every colour with a label or a shape.
- Covers the whole page with JavaScript disabled; Mermaid blocks fall back to their source text.
- `lang` on `<html>`, and a `title` that names the subject.

## Tone

- Plain English. Lead with the verdict, then the evidence.
- If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it.
- Use the project's own nouns. A term invented for the report costs the reader a lookup.
- No hedging, no throat-clearing, no "it is worth noting that".
