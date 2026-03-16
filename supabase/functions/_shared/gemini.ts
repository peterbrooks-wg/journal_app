const GEMINI_MODEL = 'gemini-2.0-flash';
const GEMINI_BASE_URL =
  'https://generativelanguage.googleapis.com/v1beta/models';

/** The structured response we expect from Gemini. */
export interface WeeklySummaryResponse {
  summary: string;
  themes: string[];
  growth_observation: string;
  prompts: string[];
}

/** JSON schema for Gemini structured output. */
const weeklySummarySchema = {
  type: 'object',
  properties: {
    summary: {
      type: 'string',
      description: '2-3 paragraph weekly summary of journal entries',
    },
    themes: {
      type: 'array',
      items: { type: 'string' },
      minItems: 1,
      maxItems: 5,
      description: 'Key themes from the entries',
    },
    growth_observation: {
      type: 'string',
      description:
        'One sentence noting personal growth or positive change',
    },
    prompts: {
      type: 'array',
      items: { type: 'string' },
      minItems: 3,
      maxItems: 3,
      description: '3 personalized writing prompts for next week',
    },
  },
  required: ['summary', 'themes', 'growth_observation', 'prompts'],
};

const SYSTEM_INSTRUCTION = `You are a compassionate journaling companion. \
Analyze the user's journal entries and provide a thoughtful weekly summary. \
Be warm but not saccharine. Notice patterns and growth. Never judge or diagnose.`;

/**
 * Calls Gemini 2.0 Flash to generate a weekly summary.
 *
 * Uses structured JSON output so the response is guaranteed to
 * match our schema.
 */
export async function generateWeeklySummary(
  runningSummary: string,
  entries: { date: string; mood: string | null; content: string }[],
): Promise<WeeklySummaryResponse> {
  const apiKey = Deno.env.get('GEMINI_API_KEY');
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is not set');
  }

  const entriesText = entries
    .map(
      (e, i) =>
        `Entry ${i + 1} (${e.date}${e.mood ? ` — mood: ${e.mood}` : ''}):\n${e.content}`,
    )
    .join('\n\n');

  const userMessage = runningSummary
    ? `Here is the user's running context from previous weeks:\n${runningSummary}\n\nHere are their new journal entries this week:\n\n${entriesText}\n\nPlease provide a weekly summary with themes, a growth observation, and 3 personalized prompts.`
    : `Here are the user's journal entries this week:\n\n${entriesText}\n\nPlease provide a weekly summary with themes, a growth observation, and 3 personalized prompts.`;

  const url = `${GEMINI_BASE_URL}/${GEMINI_MODEL}:generateContent`;

  const response = await fetch(`${url}?key=${apiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      system_instruction: {
        parts: [{ text: SYSTEM_INSTRUCTION }],
      },
      contents: [
        {
          role: 'user',
          parts: [{ text: userMessage }],
        },
      ],
      generationConfig: {
        responseMimeType: 'application/json',
        responseJsonSchema: weeklySummarySchema,
        maxOutputTokens: 1500,
        temperature: 0.7,
      },
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(
      `Gemini API error (${response.status}): ${errorBody}`,
    );
  }

  const data = await response.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;

  if (!text) {
    throw new Error('Gemini returned empty response');
  }

  return JSON.parse(text) as WeeklySummaryResponse;
}
