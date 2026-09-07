# Agent skills

Place repository-managed agent skills in this directory, one directory per
skill:

```text
skills/
└── example-skill/
    ├── SKILL.md
    └── ...
```

Every immediate child directory must contain a `SKILL.md`. The Home Manager
module at `modules/home/agent-skills/` discovers these directories and links
each one to `~/.agents/skills/<name>`. Files directly under `skills/`, such as
this README, are not installed.
