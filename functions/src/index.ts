import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

admin.initializeApp();

type EstimatedNutrition = {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  servingSizeText: string;
};

type FoodComponent = {
  name: string;
  estimatedGrams: number;
};

type GeminiFoodItem = {
  detectedName: string;
  confidence: number;
  estimatedNutrition: EstimatedNutrition;
  components: FoodComponent[];
};

function toNumber(value: unknown, fallback: number): number {
  const n = Number(value);
  if (Number.isFinite(n)) {
    return n;
  }

  return fallback;
}

function createFallbackFoodItem(
  raw: string,
  confidence = 0.4
): GeminiFoodItem {
  const detectedNameMatch = raw.match(/"detectedName"\s*:\s*"([^"]+)"/);

  const detectedName =
    detectedNameMatch?.[1]?.trim() || "อาหารไทยไม่ทราบชนิด";

  return {
    detectedName,
    confidence,
    estimatedNutrition: {
      calories: 500,
      protein: 20,
      carbs: 60,
      fat: 18,
      servingSizeText: "1 จานโดยประมาณ",
    },
    components: [
      {
        name: "ข้าวสวย",
        estimatedGrams: 180,
      },
      {
        name: "เนื้อสัตว์สุก",
        estimatedGrams: 100,
      },
    ],
  };
}

function extractJsonArray(raw: string): GeminiFoodItem[] {
  try {
    const cleaned = raw
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    logger.info("Gemini raw response", {
      rawText: cleaned.substring(0, 1000),
    });

    const start = cleaned.indexOf("[");
    const end = cleaned.lastIndexOf("]");

    if (start === -1 || end === -1 || end <= start) {
      logger.error("JSON array not found in Gemini response", {
        raw: cleaned.substring(0, 1000),
      });

      return [createFallbackFoodItem(cleaned, 0.5)];
    }

    const jsonText = cleaned.substring(start, end + 1);
    const parsed = JSON.parse(jsonText);

    if (!Array.isArray(parsed)) {
      logger.error("Parsed Gemini response is not array", {
        parsed,
      });

      return [createFallbackFoodItem(cleaned, 0.5)];
    }

    const items: GeminiFoodItem[] = parsed
      .map((item: any) => {
        const nutrition = item.estimatedNutrition ?? {};

        const rawComponents = Array.isArray(item.components)
          ? item.components
          : [];

        const components: FoodComponent[] = rawComponents
          .map((component: any) => {
            return {
              name: String(component.name ?? "").trim(),
              estimatedGrams: Math.max(
                0,
                toNumber(component.estimatedGrams, 0)
              ),
            };
          })
          .filter((component: FoodComponent) => {
            return component.name.length > 0;
          })
          .slice(0, 3);

        return {
          detectedName: String(item.detectedName ?? "").trim(),
          confidence: Math.max(
            0,
            Math.min(1, toNumber(item.confidence, 0.7))
          ),
          estimatedNutrition: {
            calories: Math.max(0, toNumber(nutrition.calories, 0)),
            protein: Math.max(0, toNumber(nutrition.protein, 0)),
            carbs: Math.max(0, toNumber(nutrition.carbs, 0)),
            fat: Math.max(0, toNumber(nutrition.fat, 0)),
            servingSizeText: String(
              nutrition.servingSizeText ?? "1 จานโดยประมาณ"
            ),
          },
          components,
        };
      })
      .filter((item: GeminiFoodItem) => {
        return item.detectedName.length > 0;
      });

    if (items.length === 0) {
      return [createFallbackFoodItem(cleaned, 0.4)];
    }

    return items;
  } catch (error) {
    logger.error("JSON parse error", {
      error,
      message: error instanceof Error ? error.message : String(error),
      raw: raw.substring(0, 1000),
    });

    return [createFallbackFoodItem(raw, 0.4)];
  }
}

export const analyzeFoodImage = onCall(
  {
    region: "asia-southeast1",
    timeoutSeconds: 60,
    memory: "512MiB",
  },
  async (request) => {
    logger.info("analyzeFoodImage called", {
      hasAuth: !!request.auth,
      uid: request.auth?.uid ?? null,
      hasData: !!request.data,
      hasImageBase64: !!request.data?.imageBase64,
      imageBase64Length:
        typeof request.data?.imageBase64 === "string"
          ? request.data.imageBase64.length
          : 0,
      mimeType: request.data?.mimeType ?? null,
    });

    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "กรุณาเข้าสู่ระบบก่อนใช้งาน AI Scan"
      );
    }

    const apiKey = process.env.GEMINI_API_KEY;

    if (!apiKey) {
      logger.error("Missing GEMINI_API_KEY");

      throw new HttpsError(
        "failed-precondition",
        "ยังไม่ได้ตั้งค่า GEMINI_API_KEY"
      );
    }

    const imageBase64 = request.data?.imageBase64;
    const mimeType = request.data?.mimeType ?? "image/jpeg";

    if (!imageBase64 || typeof imageBase64 !== "string") {
      throw new HttpsError("invalid-argument", "ไม่พบข้อมูลรูปภาพ");
    }

    const prompt = `
วิเคราะห์รูปอาหารไทย และตอบเป็น JSON array เท่านั้น ห้าม markdown ห้ามคำอธิบายอื่น

ให้ตอบ "1 เมนูหลัก" ที่เห็นเด่นที่สุดในภาพเท่านั้น

รูปแบบ JSON:
[
  {
    "detectedName": "ชื่อเมนูภาษาไทย",
    "confidence": 0.9,
    "estimatedNutrition": {
      "calories": 500,
      "protein": 25,
      "carbs": 60,
      "fat": 15,
      "servingSizeText": "1 จาน"
    },
    "components": [
      { "name": "ข้าวสวย", "estimatedGrams": 180 },
      { "name": "เนื้อสัตว์สุก", "estimatedGrams": 100 },
      { "name": "ไข่ดาว", "estimatedGrams": 60 }
    ]
  }
]

กติกา:
- ตอบเพียง 1 object ภายใน array
- ต้องมีอาหารอย่างน้อย 1 รายการเสมอ
- ถ้าไม่แน่ใจ ให้เดาเมนูอาหารไทยที่ใกล้เคียงที่สุด
- estimatedNutrition คือค่าประมาณของเมนูนั้น
- calories เป็น kcal
- protein, carbs, fat เป็นกรัม
- components ใช้สำหรับระบบคำนวณกรัม
- components ห้ามเกิน 3 รายการ
- component name ให้เป็นวัตถุดิบพื้นฐาน เช่น ข้าวสวย, หมูสุก, ไก่สุก, ไข่ดาว, กุ้งสด, เส้นก๋วยเตี๋ยว
- ห้ามตอบ array ว่าง
- ห้ามใส่ข้อความนอก JSON
`;

    const endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" +
      encodeURIComponent(apiKey);

    const body = {
      contents: [
        {
          parts: [
            {
              text: prompt,
            },
            {
              inline_data: {
                mime_type: mimeType,
                data: imageBase64,
              },
            },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.1,
        maxOutputTokens: 2048,
      },
    };

    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      });

      if (!response.ok) {
        const errorText = await response.text();

        logger.error("Gemini API error", {
          status: response.status,
          body: errorText,
        });

        throw new HttpsError(
          "internal",
          `Gemini API error ${response.status}: ${errorText.substring(0, 500)}`
        );
      }

      const json = await response.json();

      logger.info("Gemini response received", {
        hasCandidates: Array.isArray(json?.candidates),
        candidatesLength: json?.candidates?.length ?? 0,
      });

      const text =
        json?.candidates?.[0]?.content?.parts
          ?.map((part: any) => part.text ?? "")
          .join("\n") ?? "";

      if (!text) {
        logger.error("Gemini returned empty text", {
          response: JSON.stringify(json).substring(0, 1000),
        });

        return {
          success: true,
          detectedItems: [
            createFallbackFoodItem("อาหารไทยไม่ทราบชนิด", 0.3),
          ],
        };
      }

      const items = extractJsonArray(text);

      logger.info("Food detection result", {
        count: items.length,
        items,
      });

      return {
        success: true,
        detectedItems: items,
      };
    } catch (error) {
      logger.error("analyzeFoodImage error", {
        error,
        message: error instanceof Error ? error.message : String(error),
      });

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        error instanceof Error
          ? error.message
          : "เกิดข้อผิดพลาดขณะวิเคราะห์รูปอาหาร"
      );
    }
  }
);