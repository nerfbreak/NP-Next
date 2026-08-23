# 9Router Setup for NP-Next

## Purpose

This document describes the external 9Router configuration required to make the repository's quota-aware AI routing policy operational.

The repository does not store 9Router credentials, private endpoints, or environment-specific Combo IDs.

## Quota buckets

### WRL

All `wrl/*` models share one WRL API quota.

Recommended primary models:

- Reasoning: `wrl/claude-opus-5`
- Coding/worker: `wrl/gpt-5.6-sol`
- Migration analysis: `wrl/gpt-5.6-luna`
- UI: `wrl/claude-sonnet-5`

### Thinking

One shared quota:

- `4.6-Opus-Thinking`
- `4.6-Sonnet-Thinking`

### Gemini Flash 3.7

One shared quota:

- `3.7-Flash-High`
- `3.7-Flash-Medium`
- `3.7-Flash-Low`

### Free

Last-resort models available in the live local catalog, including the free models visible to the user.

## Required Combos

Create these five logical Combos in 9Router:

### NP-Next-REASONING

WRL reasoning primary
→ Thinking bucket
→ Gemini Flash High
→ Free pool

### NP-Next-CODING

WRL coding primary
→ Thinking bucket
→ Gemini Flash High
→ Free pool

### NP-Next-UI

WRL UI primary
→ Thinking bucket
→ Gemini Flash High
→ Free pool

### NP-Next-QA

Gemini Flash Medium
→ WRL lightweight model
→ Free pool

### NP-Next-CHEAP

Gemini Flash Low
→ Free pool

## Important quota rule

Do not create a fallback chain that treats models within the same quota bucket as independent capacity.

Examples that are NOT independent quota fallbacks:

- `wrl/gpt-5.6-sol` → `wrl/claude-sonnet-5`
- `4.6-Opus-Thinking` → `4.6-Sonnet-Thinking`
- `3.7-Flash-High` → `3.7-Flash-Medium` → `3.7-Flash-Low`

Those are model substitutions inside the same quota bucket.

The meaningful fallback boundary is between buckets.

## Autonomous behavior

The router should absorb:

- quota exhaustion
- provider rate limit
- transient provider failure
- model availability failure

The agent should continue automatically when a healthy fallback bucket is available.

Escalate to the user only when:

- all relevant fallback buckets are exhausted, or
- the task hits a real blocker such as access failure, contradictory requirements, unsafe recovery, destructive migration approval, or unverifiable legacy behavior.

## OpenCode integration

After the five Combos are created, run the OpenCode model catalog command and use the exact Combo IDs exposed by the local provider configuration.

Do not guess Combo IDs.
Do not commit environment-specific Combo IDs until the local catalog confirms them.

The project agents already define the routing intent. The external Combo IDs are the environment-specific binding.
