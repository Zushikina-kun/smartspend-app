# Google Forms Fix — Exact Copy-Paste Guide
**For:** Brix A. Directo
**Time needed:** ~15 minutes
**Do this TODAY** — surveys are live with invalid instructions

Forms:
- SUS (2 min): https://docs.google.com/forms/d/e/1FAIpQLScs24mLCXnSpCZnqDJt46wSWXQUsxhgu0GBkMAlYcOo8oAf2g/viewform
- Research Survey (5 min): https://docs.google.com/forms/d/e/1FAIpQLSfuDVpOSzTCQ8ICl-FGDjZ9a7iGPpKsh51xxAJ6ajesM36DXQ/viewform

To edit: go to docs.google.com/forms → open each form → click the pencil/edit icon

---

## FORM 1 — SUS Evaluation Survey

### Change 1 — Form Title/Description (the intro text at the very top)

**Current (wrong):**
> "Whether you've used the app or not — your responses count."
> (or similar text that doesn't require app use)

**Replace the entire form description with this:**

```
Before answering, please try SmartSpend (or use the "Try Demo" option on the login screen) for about 10 minutes first.

Download the app: https://zushikina-kun.github.io/smartspend-app/

This survey is for a Lorma Colleges capstone research study on a personal finance app. Participation is voluntary. We do not collect your name or bank details. Answers are used only for academic research and reported in group form. You may stop at any time.
```

### Change 2 — Add a screening question as Question 1

**Add a new Multiple Choice question at the very top (before all other questions):**

Question text:
```
Did you use SmartSpend (or the Try Demo mode) for at least 10 minutes before answering this survey?
```

Options:
```
○ Yes — I tried the app
○ No — I have not used the app yet
```

**Important:** In Form Settings → Responses → enable "Response validation" or use a Section. The easiest way:
- Make "No" lead to a section that says "Thank you! Please try the app first, then come back to this survey." and ends the form.
- Make "Yes" continue to the SUS questions.

*(If you can't figure out the section branching, just leave it as a regular question — Claude can filter out "No" responses when computing the SUS score.)*

### Change 3 — Add 18+ confirmation

**Add another question after the screening question:**

Question text:
```
I confirm that I am 18 years old or above.
```

Type: Checkbox (required)

Options:
```
☐ Yes, I am 18 or older
```

*(Make it required so they can't skip it.)*

### Change 4 — Add demographic questions

**Add these questions before the SUS items** (after the screening + 18+ check):

**Q: Age range**
Type: Multiple choice
```
○ 18–24
○ 25–34
○ 35–44
○ 45–55
○ 56 or older
```

**Q: Occupation**
Type: Multiple choice
```
○ Student
○ Employed (full-time or part-time)
○ Freelancer / Self-employed
○ Household manager / Stay-at-home parent
○ Other
```

**Q: City or province**
Type: Short answer (optional, not required)

**Q: Phone brand and approximate RAM**
Type: Multiple choice
```
○ Samsung (4 GB RAM)
○ Samsung (6 GB RAM or more)
○ Xiaomi / Redmi / POCO
○ realme
○ OPPO / Vivo
○ iPhone
○ Other Android phone
```
*(This helps explain Local AI limitations in the manuscript.)*

### Change 5 — Verify SUS items use standard wording

Check that the 10 SUS questions are in this exact order and wording (Brooke, 1996):

1. I think that I would like to use this system frequently.
2. I found the system unnecessarily complex.
3. I thought the system was easy to use.
4. I think that I would need the support of a technical person to be able to use this system.
5. I found the various functions in this system were well integrated.
6. I thought there was too much inconsistency in this system.
7. I would imagine that most people would learn to use this system very quickly.
8. I found the system very cumbersome to use.
9. I felt very confident using the system.
10. I needed to learn a lot of things before I could get going with this system.

Each uses a 1–5 scale: **1 = Strongly Disagree, 5 = Strongly Agree**

### Change 6 — Check that the form does NOT collect email addresses

Go to Settings (gear icon) → check "Collect email addresses" — make sure it is **OFF** if the form says "Anonymous".

---

## FORM 2 — Research Survey (Financial Management Practices)

### Change 1 — Form description

**Replace the intro text with:**

```
This survey is part of a capstone research study at Lorma Colleges, College of Computer Studies and Engineering. We are studying the financial management practices, budgeting challenges, and expense tracking behaviors of parents and young professionals in San Fernando City, La Union.

You do NOT need to have used SmartSpend to answer this survey.

Participation is voluntary. We do not collect your name or bank account details. Answers are used only for academic research (Lorma Colleges CCSE Capstone 2026) and reported in group form. You may stop at any time. Questions? Contact us at [your team email or Facebook page].
```

### Change 2 — Add 18+ confirmation as Question 1

**Add at the very top:**

Question text:
```
I confirm that I am 18 years old or above and I voluntarily agree to participate in this research survey.
```

Type: Checkbox (required)
Options:
```
☐ Yes, I understand and agree
```

### Change 3 — Verify demographic questions match target groups

Make sure the form collects:
- Age (check that you have the age bands that capture parents 35–55 and young professionals 21–35)
- Occupation category
- City/municipality (you need to know they're from La Union or the surrounding area for the manuscript)

### Change 4 — Check email collection is OFF

Same as Form 1 — Settings → Collect email addresses → OFF.

---

## AFTER EDITING BOTH FORMS

### Test the forms yourself
1. Open each form as a respondent (use Incognito mode)
2. Try answering "No" on the SUS screening — confirm it ends the form with a thank-you
3. Try answering "Yes" — confirm all SUS questions appear
4. Submit a test response, then delete it from the Responses tab

### Update the website SUS banner
The website still needs one more line added. Go to the website research section banner and add near the SUS button:

> "⚠️ Please try the app for about 10 minutes first before answering the SUS survey."

*(Kiro already updated the main banner — this is just a reminder near the actual button.)*

### Share the surveys NOW with this caption

**For Facebook / group chats (Filipino):**

> 🎓 Kailangan namin ng tulong para sa aming capstone sa Lorma Colleges!
>
> **Para sa SUS survey (2 minuto):** I-try muna ang SmartSpend ng mga 10 minuto, tapos sagutin ang survey:
> 👉 [SUS link: https://docs.google.com/forms/d/e/1FAIpQLScs24mLCXnSpCZnqDJt46wSWXQUsxhgu0GBkMAlYcOo8oAf2g/viewform]
>
> **Para sa research survey (3–5 minuto) — kahit hindi pa nakakapagtry ng app:**
> 👉 [Research link: https://docs.google.com/forms/d/e/1FAIpQLSfuDVpOSzTCQ8ICl-FGDjZ9a7iGPpKsh51xxAJ6ajesM36DXQ/viewform]
>
> 18 taong gulang pataas lang po. Anonymous at para lang sa pag-aaral. Salamat! 🙏
> 
> Download ang app dito: https://zushikina-kun.github.io/smartspend-app/

**For classmates / group chats (shorter):**

> Help naman! Sagutan ng SmartSpend survey namin para sa capstone. 2 minuto lang.
> I-try muna ang app (may Try Demo), tapos:
> SUS survey: [link]
> Research survey (no app needed): [link]
> Salamat!

---

## TRACKING RESPONSES

Once forms are fixed, check responses daily at:
- docs.google.com/forms → open form → Responses tab → green Sheets icon to export

**Target:** 30 valid SUS responses (answered "Yes" to the screening question) by November 5.

If you only get 20 by Nov 4 — tell Claude. The manuscript can be written with N=20 as long as it's the real number.

---

*Created: November 1, 2026*
*These forms need to be fixed BEFORE sharing more widely.*
