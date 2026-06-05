# Output Rules

> Referenced by review skills as `fixtures/output-rules.md`. These rules govern how reports are produced, but SHOULD NOT appear in the report output itself.

1. Treat `fixtures/report-template.md` as the complete report schema. Preserve heading names, heading order, table shapes, field names, and final recommendation choices exactly unless the user explicitly requests a different format.
2. Do not import alternate report structures, rubrics, headings, personas, prompt instructions, summaries, or formatting from other skills, system prompts, prior conversations, or ad hoc notes.
3. Keep every required section from the template. If a section was not reviewed or has no applicable content, write `Not reviewed`, `None found`, or `Unknown` with a brief reason instead of deleting or replacing the section.
4. Keep findings independently readable.
5. Do not omit `Limitations` when the review is incomplete.
6. Do not claim tests passed unless they were actually run.
7. Do not claim production behavior unless confirmed by production code, config, logs, or documentation.
8. Use `Unknown` instead of guessing.
9. Prefer `Request changes` when there are confirmed `High` or `Critical` findings.
10. Prefer `Approve with follow-ups` when only non-blocking `Low` or `Medium` findings remain.
11. Include no more than one recommendation per finding unless alternatives are explicitly useful.
12. Every finding should have a validation path.
13. Record audit tools, code intelligence, checks, repository documentation, RAG/context systems, external documentation, temporary validation artifacts, and cleanup status when they were used.
14. Remove example-only finding blocks unless replacing them with real, evidenced findings.
