import { config } from './deps.ts';

const env = config();

export const PINATA_API_KEY = env.PINATA_API_KEY;
export const PINATA_SECRET_KEY = env.PINATA_SECRET_KEY;
export const BLOCKFROST_PROJ = env.BLOCKFROST_PROJ;
export const MNEMONIC = env.MNEMONIC;
export const DAO_ADDRESS = env.DAO_ADDRESS;
export const PORT = env.PORT;
export const FIREBASE_API_KEY=env.FIREBASE_API_KEY;
export const FIREBASE_AUTH_DOMAIN=env.FIREBASE_AUTH_DOMAIN;
export const FIREBASE_DATABASE_URL=env.FIREBASE_DATABASE_URL;
export const FIREBASE_PROJECT_ID=env.FIREBASE_PROJECT_ID;
export const FIREBASE_STORAGE_BUCKET=env.FIREBASE_STORAGE_BUCKET;
export const FIREBASE_MESSAGING_SENDER_ID=env.FIREBASE_MESSAGING_SENDER_ID;
export const FIREBASE_APP_ID=env.FIREBASE_APP_ID;