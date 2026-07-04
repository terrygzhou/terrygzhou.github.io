---
title: "Using ArcKit TOGAF ADM: A Guide for Non-Technical Users"
date: 2026-07-02
tags:
  - ArcKit
  - TOGAF ADM
  - AI Agents
  - Enterprise Architecture
status: draft
---
	 
# Using ArcKit TOGAF ADM: A Guide for Non-Technical Users

## What is this plugin?

ArcKit TOGAF ADM is an AI-powered tool that helps enterprise architects navigate the TOGAF Architecture Development Method (ADM). It provides a structured, step-by-step approach to creating architecture documentation, from initial visioning to governance and repository management.

## How to Install (3 Ways)

### Method 1: Local Development (Recommended for Testing)

Load the plugin directly from your local clone:

```bash
# Clone the repository first
git clone https://github.com/terrygzhou/arc-kit.git
cd arc-kit

# Launch with the plugin
claude --plugin-dir ./plugins/arckit-togaf-adm
```

### Method 2: Permanent Install

Copy the plugin to your Claude Code plugin directory:

```bash
# Find your plugin directory
claude plugin list

# Copy the plugin
cp -r ./plugins/arckit-togaf-adm/.claude-plugin ~/.claude/plugins/arckit-togaf-adm
```

### Method 3: GitHub Install

Install directly from the GitHub repository:

```bash
claude plugin install https://github.com/terrygzhou/arc-kit/plugins/arckit-togaf-adm
```

## Alternative Usage Methods

### As a Standalone Tool

Use the plugin without Claude Code by reading the command files directly:

```bash
# Each command is a markdown file
cat ./plugins/arckit-togaf-adm/commands/adm-preliminary.md
```

### In CI/CD Pipelines

Automate architecture reviews in your deployment pipeline:

```yaml
# GitHub Actions example
- name: Architecture Review
  run: |
    claude --plugin-dir ./plugins/arckit-togaf-adm \
      /arckit-togaf-adm:gap-analysis "current vs target state"
```

### For Team Workshops

Use the plugin to facilitate architecture workshops:

1. Share the command reference with participants
2. Run commands collaboratively during whiteboarding sessions
3. Save outputs to shared documentation repositories

## Available Commands

The plugin provides nine architecture-focused commands:

| Command | Purpose |
|---------|---------|
| `/arckit-togaf-adm:adm-preliminary` | Define project scope, vision, and success criteria |
| `/arckit-togaf-adm:application-inventory` | Catalog existing applications |
| `/arckit-togaf-adm:application-rationalization` | Decide which apps to keep, merge, or retire |
| `/arckit-togaf-adm:architecture-board` | Set up governance and compliance processes |
| `/arckit-togaf-adm:architecture-change` | Manage changes to architecture decisions |
| `/arckit-togaf-adm:business-capability-map` | Map business capabilities |
| `/arckit-togaf-adm:gap-analysis` | Identify gaps between current and target states |
| `/arckit-togaf-adm:transition-architecture` | Plan the transition roadmap |
| `/arckit-togaf-adm:architecture-repository` | Organize and document architecture artifacts |

## Example: Starting an Architecture Project

```bash
claude --plugin-dir ./plugins/arckit-togaf-adm
/arckit-togaf-adm:adm-preliminary "enterprise digital transformation"
```

The AI will guide you through:
- Defining scope and drivers
- Setting success criteria
- Identifying constraints
- Creating an architecture vision document

## Best Practices

1. **Start with `adm-preliminary`** — it sets the foundation for all other commands
2. **Follow the TOGAF sequence** — Preliminary → Capability Mapping → Gap Analysis → Transition Planning
3. **Document everything** — all outputs are saved as structured markdown notes
4. **Review with your team** — use the architecture board command to establish governance

## Common Issues

- **Commands not showing**: Ensure you're using `--plugin-dir` to load the plugin
- **Missing dependencies**: The plugin requires the `arckit` core overlay (auto-installed)

## Next Steps

- Explore `arckit-agent-architecture` for AI agent-specific governance
- Check `arckit-togaf-adm` for traditional enterprise architecture workflows