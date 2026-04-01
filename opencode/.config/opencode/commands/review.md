---
description: Review recent changes for bugs, security, and style
agent: plan
subtask: true
---

Review the following changes for bugs, security issues, performance problems, and style violations:

```
$!git diff HEAD~1
```

Provide a structured review with sections:
- **Critical Issues** -- bugs, security flaws, data loss risks
- **Suggestions** -- improvements to logic, readability, or performance
- **Nits** -- minor style or naming concerns

Delegate security-specific analysis to @security.
