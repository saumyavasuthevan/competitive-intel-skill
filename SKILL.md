---
name: competitive-intel
description: |
  Generate and send automated competitive intelligence reports via email.
  
  Use when the user asks for:
  - "competitive intelligence report"
  - "competitor analysis"
  - "competitive landscape report"
  - "send me a competitive report"
  - Any request involving analyzing competitors and sending an email report
  
  This skill orchestrates a 5-step workflow:
  1. Ask for the target company name
  2. Research and identify the company + top 10 competitors
  3. Present findings for user confirmation
  4. Generate a structured competitive report following strict template
  5. Send the report via Gmail to the specified recipient
  
  IMPORTANT: This skill ONLY uses competitive intelligence from the PAST 7 DAYS.
  Articles older than one week are considered stale and excluded from reports.
---

# Competitive Intelligence Report Skill

Generate professional competitive intelligence reports and deliver them via email.

## Workflow

Follow this exact 5-step sequence:

### Step 1: Get Company Name
Ask the user: "What company would you like me to analyze for the competitive intelligence report?"

Wait for their response before proceeding.

### Step 2: Research Company & Competitors

Use `web_search` to find:
1. Confirm the company exists and get basic info
2. Identify top 10 competitors

Search queries to run:
- `"[Company Name]" company overview`
- `"[Company Name]" top competitors`
- `"[Company Name]" vs competitors landscape`

Extract:
- Confirmed company name (use official/legal name)
- Industry/sector
- Top 10 competitor names (prioritize direct competitors over indirect)

### Step 3: Present for Confirmation

Format your response exactly like this:

```
**Target Company:** [Official Company Name]
**Industry:** [Industry/Sector]

**Top 10 Competitors Identified:**
1. [Competitor 1]
2. [Competitor 2]
3. [Competitor 3]
4. [Competitor 4]
5. [Competitor 5]
6. [Competitor 6]
7. [Competitor 7]
8. [Competitor 8]
9. [Competitor 9]
10. [Competitor 10]

Does this look correct? Reply "yes" to proceed with the report, or let me know what to change.
```

Wait for user confirmation before proceeding to Step 4.

### Step 4: Generate the Report

Once confirmed, research **RECENT** competitive developments from the **PAST 7 DAYS ONLY**:

**CRITICAL TIME CONSTRAINT: Only use news from the past week (last 7 days).** Articles from January when it's February are too old and irrelevant.

For EACH competitor (including target company), search for:
- Recent product launches/updates (past 7 days)
- Pricing changes (past 7 days)
- Partnerships or acquisitions (past 7 days)
- Strategic pivots or announcements (past 7 days)

Use targeted searches with **freshness filter for past week**:
- `"[Competitor Name]" news past week`
- `"[Competitor Name]" product launch this week`
- `"[Competitor Name]" partnership this week`
- `"[Competitor Name]" announcement February 2026`

**If no results from past 7 days:** Expand to past 14 days maximum. If still nothing, skip that competitor and find a different one with recent news.

**Date Verification:** Check article dates before using. Reject any article older than 7 days unless it's breaking major news from 8-14 days ago.

Select the 3 most significant competitive developments from the **past 7 days** to feature in the report.

**Source Requirements:**
- Save the exact URL from each web_search result
- Include clickable HTML source link at the end of each "Why it matters" paragraph
- Format: `(<em>Source: <a href='EXACT_URL'>Publication Name</a></em>)`
- Use HTML tags for all formatting (<h2>, <h3>, <strong>, <a href='...'>, etc.)

#### Report Template (STRICT FORMAT - HTML ONLY)

**CRITICAL: Use HTML tags, NOT Markdown. Gmail requires HTML for proper formatting.**

```html
Subject: Competitive Intel: [Target Company Name] | [Current Date]

<html><body style='font-family:Arial,sans-serif;line-height:1.6;color:#333;'>

<h2 style='color:#1a1a1a;border-bottom:2px solid #4285f4;padding-bottom:8px;'>⚡️ TL;DR</h2>
<ul style='padding-left:20px;'>
<li>[Bullet 1: 15 words or less]</li>
<li>[Bullet 2: 15 words or less]</li>
<li>[Bullet 3: 15 words or less]</li>
</ul>

<h2 style='color:#1a1a1a;border-bottom:2px solid #4285f4;padding-bottom:8px;margin-top:30px;'>💡 The Rundown</h2>

<h3 style='color:#1a73e8;margin-top:20px;'>[Headline for Delta 1]:</h3>
<p>[Narrative summary, 1-2 sentences]</p>
<p><strong>Why it matters:</strong> [Insightful analysis, 1-2 sentences] (<em>Source: <a href='EXACT_URL'>Publication Name</a></em>)</p>

<h3 style='color:#1a73e8;margin-top:20px;'>[Headline for Delta 2]:</h3>
<p>[Narrative summary, 1-2 sentences]</p>
<p><strong>Why it matters:</strong> [Insightful analysis, 1-2 sentences] (<em>Source: <a href='EXACT_URL'>Publication Name</a></em>)</p>

<h3 style='color:#1a73e8;margin-top:20px;'>[Headline for Delta 3]:</h3>
<p>[Narrative summary, 1-2 sentences]</p>
<p><strong>Why it matters:</strong> [Insightful analysis, 1-2 sentences] (<em>Source: <a href='EXACT_URL'>Publication Name</a></em>)</p>

<hr style='border:none;border-top:1px solid #ddd;margin:30px 0;'>
<p style='font-size:12px;color:#666;'>This email was created by OpenClaw. Enjoyed this newsletter? Email <a href='mailto:[recipient email]'>[recipient email]</a> for more automated Product Manager workflows.</p>

</body></html>
```

**Critical formatting rules:**
- Use HTML tags ONLY: `<h2>`, `<h3>`, `<strong>`, `<a href='...'>`, `<em>`, `<ul>`, `<li>`
- NEVER use Markdown (no `**` asterisks for bold)
- TL;DR bullets must be 15 words or less each
- Include clickable source links at the END of each "Why it matters" paragraph using `<a href='URL'>Name</a>`
- Use `<h2>` for section headings (⚡️ TL;DR, 💡 The Rundown)
- Use `<h3>` for each delta headline (renders as bold with color)
- Use `<strong>` for "Why it matters:" label
- Use the ⚡️ and 💡 emojis exactly as shown
- Three deltas required, each with "Why it matters" analysis
- End with the exact footer text
- Current date format: Month Day, Year (e.g., "January 15, 2025")

### Step 5: Send via Gmail

Save the HTML report to a file and send using gog:

```bash
# Save HTML to file
cat > /tmp/report.html <<'HTMLEOF'
[Your HTML report content here]
HTMLEOF

# Send with --body-html flag
gog gmail send \
  --to [receipient email] \
  --from [sender email] \
  --subject "Competitive Intel: [Company] | [Date]" \
  --body-html "$(cat /tmp/report.html)"
```

**Important:** 
- Use `--from [sender email]` (sender)
- Use `--to [receipient email]` (recipient)
- Use `--body-html` (NOT --body or --body-file) for HTML formatting
- Confirm successful send before completing

## Example Output Style (HTML Format)

Follow this tone and structure exactly:

```html
<html><body style='font-family:Arial,sans-serif;line-height:1.6;color:#333;'>

<h2 style='color:#1a1a1a;border-bottom:2px solid #4285f4;padding-bottom:8px;'>⚡️ TL;DR</h2>
<ul style='padding-left:20px;'>
<li>Stripe launched "Adaptive Pricing" in UK/EU, automating currency conversion for SMBs.</li>
<li>Adyen partnered with Klarna to integrate BNPL directly into physical POS terminals.</li>
<li>Checkout.com slashed enterprise processing fees by 0.2% to target high-volume retailers.</li>
</ul>

<h2 style='color:#1a1a1a;border-bottom:2px solid #4285f4;padding-bottom:8px;margin-top:30px;'>💡 The Rundown</h2>

<h3 style='color:#1a73e8;margin-top:20px;'>Stripe Adaptive Pricing Rollout:</h3>
<p>Stripe moved from manual to AI-driven currency localization for European merchants. This removes a significant friction point for cross-border trade.</p>
<p><strong>Why it matters:</strong> This threatens our "Global-First" USP; we must highlight our lower FX spread to retain mid-market clients. (<em>Source: <a href='https://techcrunch.com/2024/...'>TechCrunch</a></em>)</p>

<h3 style='color:#1a73e8;margin-top:20px;'>Adyen x Klarna POS Integration:</h3>
<p>Adyen is moving deeper into the physical storefront by embedding Klarna's credit options into the card reader.</p>
<p><strong>Why it matters:</strong> Our current BNPL offering is online-only; we risk losing omnichannel merchants who want a single credit provider for both web and store. (<em>Source: <a href='https://www.paymentsource.com/...'>PaymentsSource</a></em>)</p>

<h3 style='color:#1a73e8;margin-top:20px;'>Checkout.com Fee Compression:</h3>
<p>A tactical price drop specifically aimed at the $100M+ GMV segment.</p>
<p><strong>Why it matters:</strong> This is a direct play for our enterprise base. We should pivot our messaging from "Cost-Leader" to "Value/High-Uptime" to avoid a race to the bottom. (<em>Source: <a href='https://www.reuters.com/...'>Reuters</a></em>)</p>

<hr style='border:none;border-top:1px solid #ddd;margin:30px 0;'>
<p style='font-size:12px;color:#666;'>This email was created by OpenClaw. Enjoyed this newsletter? Email <a href='mailto:[recipient email]'>[recipient email]</a> for more automated Product Manager workflows.</p>

</body></html>
```

## Error Handling

- If company cannot be found: Ask user to provide more details or correct spelling
- If fewer than 5 competitors found: Expand search with broader terms
- **If no news from past 7 days for a competitor:** Skip that competitor and find another one with recent news (expand to 14 days max if needed)
- If Gmail send fails: Save report to file and inform user of failure
- If gog is not authenticated: Prompt user to run `gog auth add [sender email] --services gmail`

## Time Constraint Policy

**CRITICAL: This skill ONLY uses competitive intelligence from the past 7 days.**

- Articles from last month are considered stale and excluded
- Use web_search with `freshness="pw"` parameter for past week results
- Always verify article publication dates before including
- If no fresh news available, the report will indicate "No significant developments this week"

## Automated Setup (Recommended)

For easy configuration of automated weekly reports, run the setup wizard:

```bash
cd ~/.openclaw/workspace/skills/competitive-intel
./scripts/setup.sh
```

The wizard will interactively ask for:
1. **Target Company** - The company to analyze
2. **Recipient Email** - Where to send reports
3. **Sender Gmail** - Which Gmail account sends the reports
4. **Schedule** - Weekly, daily, or custom
5. **Timezone** - Your local timezone

Then it automatically creates the cron job with your preferences.

### Manual Setup (Alternative)

If you prefer manual configuration:

```bash
# Create custom cron job
openclaw cron add --name "Competitive Intel" \
  --schedule "0 10 * * 2" \
  --timezone "Europe/Berlin" \
  --company "YourCompany" \
  --recipient "you@example.com"
```
