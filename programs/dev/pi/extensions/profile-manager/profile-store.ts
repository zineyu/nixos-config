import { pathExists, readJson, writeJson } from "./files.js";
import {
  getProfileDir,
  getStatePath,
  validateProfileName,
} from "./profile-config.js";
import type { ProfileState } from "./profile-types.js";

export async function readState(): Promise<ProfileState> {
  return readJson(getStatePath(), {});
}

export async function writeState(state: ProfileState): Promise<void> {
  await writeJson(getStatePath(), state);
}

export async function getActiveProfile(): Promise<string | undefined> {
  return (await readState()).activeProfile;
}

export async function requireProfile(name: string): Promise<void> {
  validateProfileName(name);
  if (!(await pathExists(getProfileDir(name))))
    throw new Error(`Profile ${name} does not exist.`);
}
