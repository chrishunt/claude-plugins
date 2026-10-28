---
name: concise
description: Rewrite a piece of writing to be as concise as possible without losing important information. Use whenever the user asks to make text more concise, tighten it, shorten it, or simplify it — tickets, PR bodies, docs, chat messages, emails, announcements, any prose.
---

Rewrite the given text following these rules, in priority order:

1. **As concise as possible without losing important information.** Cut whole ideas that don't change what the reader knows or does next: restated points, defensive rationale, history the reader doesn't need, detail that belongs in a linked ticket or diff. Cutting content is how you shorten; never shorten by compressing the grammar.
2. **Full sentences, always.** No telegraphic fragments, clipped subjects or verbs, or arrow chains ("A → B → fails").
3. **Write for a reader with zero prior context.** Describe concepts as simply as possible. Gloss anything referenced inline: for an incident or event, say what happened, when, and the impact, with identifiers in parentheses after. The reader should never need to open another document to follow the text.
4. **Acronyms, code snippets, and lingo only when necessary** or when they carry most of the idea. Otherwise use plain language. Internal mechanism nouns the reader hasn't met yet count as lingo.
5. **Formatting only where it adds value.** Bullets, headings, and tables are welcome whenever they make the text easier to read or drive the point (parallel lists, todo lists, test assertions, section breaks in longer docs). The test is whether the formatting helps the reader; if a passage reads just as well as prose, leave it as prose.
6. **No dashes as separators** in prose; use commas or colons.

## Process

- Read the full original first. Identify the audience and the one thing the reader needs to take away; organize the rewrite around that.
- If a detail seems important but doesn't fit, keep it rather than silently drop it; note the judgment call when presenting the result.
- Print the rewrite inline in chat as markdown (never wrapped in ExitPlanMode). If the text lives somewhere (a ticket, a doc, a PR), offer to apply it after the user approves the draft.
- Briefly note what was cut if the reduction is large, so the user can pull anything back.

## Interaction with other skills

For PR titles and descriptions, `jig:pr-style` governs structure and register; apply these rules within it.
