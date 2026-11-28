// zod schemas shared by the server (request validation) and the web app (forms).
// Phase 0 only defines the building blocks; feature schemas are added per phase.
import { z } from 'zod';
import { PHONE_REGEX } from './constants.js';

export const phoneSchema = z.string().trim().regex(PHONE_REGEX, 'Use 03XXXXXXXXX or +923XXXXXXXXX');

export const emailSchema = z.string().trim().toLowerCase().email().max(120);

// F01: at least 8 characters with at least one letter and one digit.
export const passwordSchema = z
  .string()
  .min(8, 'At least 8 characters')
  .regex(/[A-Za-z]/, 'Must contain a letter')
  .regex(/[0-9]/, 'Must contain a digit');
