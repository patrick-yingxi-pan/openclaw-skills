---
name: debug-troubleshooting
description: "Systematic debugging and troubleshooting methodology. Follow this process when diagnosing and fixing issues."
metadata:
  author: Patrick
  version: "1.0"
  category: debugging
---

# Debug & Troubleshooting Skill

Systematic debugging and troubleshooting methodology. Follow this process when diagnosing and fixing issues.

## Quick Start

### When to Use This Skill

Use this skill when:
- You encounter an error or bug
- Something isn't working as expected
- You need to diagnose the root cause of a problem
- You want a systematic approach to troubleshooting

## Debugging Process

### Step 1: Gather Error Information

**First, find the exact error message!**

- Look at the UI (what does the user see?)
- Check browser console errors (F12 → Console)
- Check server logs
- Check database records (errorLog fields, status fields, etc.)

**Example**: In today's CASE_EXTRACTION task failure, we first looked at:
1. Admin page Recent Errors section
2. Database Task record's errorLog field
3. Found exact error: "Cannot read properties of undefined (reading 'length')"

---

### Step 2: Locate the Code That Reports the Error

**Find where in the codebase the error is being reported!**

- Search for the error message pattern in the code
- Look for error handling patterns (try/catch, updateTaskStatus with FAILED, etc.)
- Trace the call chain

**Example**: We found:
1. TaskService.handleTaskError() calls updateTaskStatus(taskId, 'FAILED', errorLog)
2. CaseCrawlerService.crawlWebsite() creates a 'CASE_EXTRACTION' task
3. The error happens during crawl execution

---

### Step 3: Find the Root Cause

**Look for the code that might trigger the error!**

- Search for patterns matching the error (e.g., ".length" access without optional chaining)
- Check for missing null/undefined checks
- Validate data flow and assumptions

**Example**: We found 3 places in CaseCrawlerService.ts:
1. Line 128: extractionResult.result.data.images.length
2. Line 143: extractionResult.result.data.images.length > 0
3. Line 148: extractionResult.result.data.images

All missing optional chaining (?.) operators!

---

### Step 4: Fix the Issue

**Apply the fix with defensive programming!**

- Add optional chaining (?.) for property access
- Add null/undefined checks
- Provide sensible default values
- Test the fix thoroughly

**Example fixes**:
- Line 128: extractionResult.result.data?.images?.length || 0
- Line 143: extractionResult.result.data?.images?.length > 0
- Line 148: extractionResult.result.data?.images || []

---

### Step 5: Verify the Fix

**Test to make sure the problem is actually solved!**

- Reproduce the issue manually
- Check that the error no longer occurs
- Verify both success and failure paths
- Check UI/logs/database to confirm

**Example verification**:
- Manually triggered CASE_EXTRACTION task
- Task completed with status: COMPLETED (not FAILED!)
- Checked Admin page: Recent Errors has no new FAILED tasks
- Confirmed no "Cannot read properties of undefined" errors

---

## Key Principles

### 1. Don't Guess - Gather Data First!

**Never start fixing without knowing the exact error!**
- Look at the actual error message
- Check logs, database, UI
- Get concrete evidence before acting

### 2. Follow the Trail - Don't Skip Steps!

**Systematic process > random attempts!**
- Error message → where reported → root cause → fix → verify
- Each step builds on the previous one
- Don't skip steps or jump to conclusions

### 3. Defensive Programming - Expect the Unexpected!

**Code should handle edge cases gracefully!**
- Use optional chaining (?.)
- Provide default values (||, ??)
- Validate assumptions about data structure
- Don't assume properties always exist

---

## Memory Aid

Remember this sequence:

1. **ERROR** → What's the exact error message?
2. **LOCATION** → Where is this error reported in code?
3. **ROOT CAUSE** → What's causing this error?
4. **FIX** → Apply defensive programming fixes
5. **VERIFY** → Test to confirm it's really solved

---

## Example Workflow (Today's CASE_EXTRACTION Fix)

### Timeline
1. **18:49** - Noticed Admin page shows CASE_EXTRACTION + FAILED
2. **19:00** - Checked database errorLog: "Cannot read properties of undefined (reading 'length')"
3. **19:15** - Located TaskService.handleTaskError() and CaseCrawlerService
4. **19:24** - Found 3 places missing optional chaining in CaseCrawlerService.ts
5. **19:30** - Applied fixes with optional chaining and default values
6. **19:47** - Manually triggered CASE_EXTRACTION task
7. **19:58** - Verified task completed successfully (COMPLETED, not FAILED!)

### Key Takeaway
The systematic process worked perfectly - we went from symptom → diagnosis → fix → verification in under an hour!

---

## License

Apache-2.0
