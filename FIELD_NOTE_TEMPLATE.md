# Field Note Template

Use this after trying Audit Evolution on your own agent.

```text
Agent:
Model:
Input type: benchmark report | worklog | task output | failure log | user feedback

Before:
- What was unclear?
- Which capability was weak?
- What did the agent tend to repeat or miss?

Audit Evolution Output:
- Snapshot:
- Evolution Card:
- Minimal Skill Patch:
- Field Note:

After:
- What became clearer?
- What is the next one-step repair?
- What evidence should be checked before promotion?

Shareable Claim:
One sentence others can test.
```

Example:

```text
Before: My agent had a good answer, but no reusable memory/update pattern.
After: Audit Evolution identified memory as the weak dimension and produced a trust-ledger patch with verified_fact, stale_claim, confidence, expiry, and retrieval_key.
Next test: Run the same benchmark once after adding only that patch.
```
