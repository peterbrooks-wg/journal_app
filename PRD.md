**Reflect**

AI-Powered Journaling App

Product Requirements Document  •  v1.0

# **1\. Overview**

Reflect is a Flutter-based iOS and Android journaling app that uses AI to help users understand themselves more deeply over time. Users write freely; the AI reads across their history to surface patterns, provide affirming weekly summaries, and generate personalized prompts that guide them toward topics worth exploring.

| Core insight: The AI isn't bolted on — it's the product. Generic journaling apps lose users after 30 days. Reflect's AI layer makes the app more valuable the longer you use it, which is the primary retention mechanism. |
| :---- |

## **1.1 Problem Statement**

* Most journaling apps are passive containers with no intelligence

* Users lose the thread of their own growth over weeks and months

* Generic prompts don't reflect a user's actual life or patterns

* People want reflection without the overhead of rereading old entries

## **1.2 Solution**

* Private, beautifully simple journaling experience

* Weekly AI summaries that synthesize themes, growth, and patterns

* Personalized prompts generated from the user's own writing history

* Affirming, psychologically grounded analysis — not generic positivity

# **2\. Target Users**

Primary: Adults 25-45 who already journal or have tried to build the habit. Secondary: People in therapy or personal development who want a private complement to that work.

| User Type | Motivation | Key Need |
| :---- | :---- | :---- |
| The Habit Builder | Wants to journal consistently but loses steam | Streak \+ momentum features; frictionless entry |
| The Self-Explorer | Uses journaling for personal growth / therapy complement | Deep AI insights; pattern recognition over time |
| The Occasional Writer | Journals during difficult periods | Low friction; compassionate tone; no pressure |

# **3\. Technical Architecture**

## **3.1 Stack**

| Frontend | Flutter (iOS \+ Android) |
| :---- | :---- |
| Backend / Auth | Supabase (Postgres, Auth, Edge Functions, Storage) |
| AI | Gemini via Supabase Edge Function proxy |
| Scheduling | Supabase pg\_cron for weekly summary jobs |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Analytics | PostHog Flutter SDK |
| Payments | RevenueCat (handles App Store \+ Play Store subscriptions) |

## **3.2 Data Model**

**users (extends Supabase auth.users)**

* id, email, created\_at

* subscription\_tier: enum (free | pro)

* onboarding\_completed: boolean

* notification\_preferences: jsonb

* timezone: text

**journal\_entries**

* id, user\_id, created\_at, updated\_at

* content: text

* word\_count: integer

* mood\_tag: text (optional, user-selected)

**ai\_summaries**

* id, user\_id, created\_at

* week\_start: date

* summary\_text: text

* themes: text\[\] (extracted by AI)

* entry\_count: integer

* word\_count\_total: integer

**ai\_prompts**

* id, user\_id, created\_at

* prompt\_text: text

* source\_themes: text\[\] (which themes triggered this prompt)

* used: boolean

* used\_at: timestamp

**running\_summaries (cost control)**

* id, user\_id

* summary\_text: text (compressed rolling context)

* last\_entry\_id: uuid (watermark — entries after this are 'new')

* updated\_at: timestamp

**usage\_tracking**

* user\_id, month: date

* ai\_prompt\_requests: integer

* summary\_count: integer

# **4\. AI Architecture**

## **4.1 Cost Control Strategy**

| Core principle: Never send full history to the AI. Use a progressive summarization pattern — maintain a running\_summary and only send new entries \+ that summary each week. Token costs stay flat regardless of how long a user has been using the app. |
| :---- |

**Weekly Summary Pipeline**

1. pg\_cron triggers Edge Function every Sunday at 8am (user timezone)

2. Fetch running\_summary \+ entries since last\_entry\_id

3. Compress entries (strip formatting, truncate \> 500 words)

4. Send to Claude: running\_summary \+ compressed new entries → new summary \+ themes \+ 3 prompts

5. Store summary in ai\_summaries, prompts in ai\_prompts, update running\_summary

6. Send FCM push notification to user

**Estimated Cost per User per Month**

| Weekly summary (Claude Haiku, \~3k tokens) | \~$0.02/month |
| :---- | :---- |
| On-demand prompts (Pro tier, 10 max/month) | \~$0.05/month |
| Total per Pro user | \~$0.07/month |
| Headroom on $6/mo subscription | $5.93 before other costs |

## **4.2 AI Prompt Design**

**Weekly Summary Prompt**

| System: You are a thoughtful, compassionate journaling companion. Your role is to help users understand their own patterns, growth, and inner life. You write with warmth and psychological insight — not generic positivity. You never project emotions onto the user or make assumptions. You find themes, ask questions, and celebrate growth without being saccharine. |
| :---- |

| User prompt structure: Previous context: {running\_summary}This week's entries ({n} entries, {word\_count} words):{compressed\_entries}Provide: (1) A warm 2-3 paragraph summary of this week's themes and patterns. (2) One observation about growth or change vs previous weeks. (3) Three personalized journal prompts that go deeper into the most resonant themes. |
| :---- |

# **5\. Feature Requirements**

## **5.1 Core Features (MVP)**

**Journal Entry**

* Tap to write — minimal chrome, full screen text area

* Auto-save every 5 seconds and on background

* Optional mood tag (5 options: good, hard, mixed, reflective, grateful)

* Word count display

* Entry history in reverse chronological list

* Search entries by keyword

**AI Weekly Summary**

* Delivered Sunday morning via push notification

* In-app Summary tab with history of past summaries

* Tap to expand full summary text

* Themes displayed as chips (e.g., 'work', 'relationships', 'growth')

* Pro feature — free users see a teaser and upgrade prompt

**AI Prompts**

* 3 new prompts generated with each weekly summary

* Displayed on home screen as 'Prompts for you'

* Tap prompt → opens new entry with prompt as header

* Prompts expire after 7 days (replaced by next week's batch)

* Free: 3 generic prompts/month. Pro: personalized from writing history.

**Auth & Onboarding**

* Supabase Auth: email magic link (no password friction)

* Apple Sign-In (required for App Store)

* Google Sign-In

* Onboarding: 3 screens — what Reflect does, privacy promise, notification opt-in

* First entry prompt on empty state

## **5.2 Pro Features**

* Weekly AI summaries (unlimited)

* Personalized prompts based on writing history

* Theme tracking over time (chart view)

* 10 on-demand prompt requests per month

* Export journal as PDF

## **5.3 Out of Scope (v1)**

* Web app

* Shared / social features

* Voice journaling

* Therapist sharing

* Android tablet / iPad optimization

# **6\. Monetization**

| Free tier | Unlimited journaling, 3 generic prompts/month, no AI summaries |
| :---- | :---- |
| Pro — $6.99/month | Weekly AI summaries, personalized prompts, theme history, PDF export |
| Pro — $49.99/year | Same as monthly, \~40% discount |
| Payment provider | RevenueCat (unified subscription management across iOS \+ Android) |
| Apple cut | 30% year 1, 15% year 2+ (small business program) |

| Revenue target: 250 Pro subscribers at $6.99/mo \= $1,747/mo gross. 300 subscribers \= $2,097/mo. Achievable within 6 months with organic App Store presence \+ content marketing. |
| :---- |

# **7\. Privacy & Security**

| Privacy is the \#1 purchase driver for journaling apps. Users will not pay for an app they don't trust with their most private thoughts. Privacy must be a first-class feature, not a policy footnote. |
| :---- |

* All entries encrypted at rest in Supabase (AES-256)

* RLS policies ensure users can only ever read their own data

* No training on user data — explicit in privacy policy and onboarding

* No third-party advertising

* Entries are never sent to the AI in real-time — only batched weekly summaries

* Option to delete all data (cascades to summaries, prompts, running\_summary)

* Export data at any time (JSON \+ PDF)

* Biometric lock option (Face ID / fingerprint)

# **8\. Milestones**

| Phase | Timeline | Deliverable |
| :---- | :---- | :---- |
| Phase 1 | Weeks 1-2 | Flutter scaffold, Supabase schema, auth, journal CRUD, basic UI |
| Phase 2 | Weeks 3-4 | AI Edge Function, weekly summary pipeline, prompt generation, push notifications |
| Phase 3 | Week 5 | RevenueCat integration, free/pro feature gates, usage tracking |
| Phase 4 | Week 6 | Onboarding polish, empty states, privacy features, biometric lock |
| Phase 5 | Week 7 | TestFlight / Play testing, bug fixes, App Store assets |
| Launch | Week 8 | App Store \+ Play Store submission |

