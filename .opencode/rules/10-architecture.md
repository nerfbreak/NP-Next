# Architecture Rules

Keep UI, API, queue and browser automation boundaries explicit. Frontend never runs Playwright. API owns authorization and orchestration. ARQ owns job transport. Workers own browser automation. Supabase owns persistent business state.
