# Security Rules

Credentials:
- encrypt distributor passwords at rest
- never return plaintext passwords after storage
- never place passwords in ARQ payloads, logs, SSE events, browser state, or error messages
- keep Supabase service credentials server-side only

Authorization:
- only SUPERUSER manages distributors, rules, users, and global settings
- OPERATOR runs supported workflows and cancels their own tasks
- sensitive database operations go through authorized server-side paths

Files:
- validate uploaded files before parsing
- treat uploaded filenames/content as untrusted
- never execute uploaded content

Logging:
- redact secrets, tokens, cookies, passwords, and sensitive session data
- log identifiers and safe metadata instead

Every security-sensitive change requires tests and reviewer attention.
