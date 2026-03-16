import { SizeKey } from "../models/product.model";

const VALID_SIZES: SizeKey[] = ["onesize", "xs", "s", "m", "l", "xl", "xxl"];

/**
 * Validates that the provided sizes map only contains valid size keys
 * and all stock values are non-negative integers.
 */
export function validateSizes(sizes: Record<string, number>): void {
  for (const [key, value] of Object.entries(sizes)) {
    if (!VALID_SIZES.includes(key as SizeKey)) {
      throw new Error(`Invalid size key: "${key}". Valid sizes: ${VALID_SIZES.join(", ")}`);
    }
    if (typeof value !== "number" || value < 0 || !Number.isInteger(value)) {
      throw new Error(`Stock for size "${key}" must be a non-negative integer. Got: ${value}`);
    }
  }
}

/**
 * Validates that a required string field is present and non-empty.
 */
export function validateRequiredString(value: unknown, fieldName: string): void {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`"${fieldName}" is required and must be a non-empty string.`);
  }
}

/**
 * Validates that a number is non-negative.
 */
export function validateNonNegativeNumber(value: unknown, fieldName: string): void {
  if (typeof value !== "number" || value < 0) {
    throw new Error(`"${fieldName}" must be a non-negative number. Got: ${value}`);
  }
}

/**
 * Validates discount percentage is between 0 and 100.
 */
export function validateDiscount(diskon: unknown): void {
  if (diskon === undefined || diskon === null) return;
  if (typeof diskon !== "number" || diskon < 0 || diskon > 100) {
    throw new Error(`"diskon" must be a number between 0 and 100. Got: ${diskon}`);
  }
}

/**
 * Validates that gambar_base64 is a non-empty array of base64 strings.
 */
export function validateBase64Images(images: unknown): void {
  if (!Array.isArray(images) || images.length === 0) {
    throw new Error(`"gambar_base64" must be a non-empty array of base64 image strings.`);
  }
  for (const img of images) {
    if (typeof img !== "string" || img.trim().length === 0) {
      throw new Error(`Each item in "gambar_base64" must be a non-empty base64 string.`);
    }
  }
}

/**
 * Validates a single base64 image string.
 */
export function validateBase64Image(image: unknown): void {
  if (typeof image !== "string" || image.trim().length === 0) {
    throw new Error(`"gambar_base64" must be a non-empty base64 string.`);
  }
}
