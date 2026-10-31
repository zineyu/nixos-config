import type { ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { disableProfileCommand } from "./disable-profile.js";
import { useProfileCommand } from "./use-profile.js";

type ProfileCommandEntrypoint = (
  args: string[],
  ctx: ExtensionCommandContext,
) => Promise<void>;

const profileCommandEntrypoints: Record<string, ProfileCommandEntrypoint> = {
  use: useProfileCommand,
  off: disableProfileCommand,
};

export async function handleProfileCommand(
  args: string | undefined,
  ctx: ExtensionCommandContext,
): Promise<void> {
  const tokens = args?.trim().split(/\s+/).filter(Boolean) ?? [];
  const [command, ...commandArgs] = tokens;
  const entrypoint = command ? profileCommandEntrypoints[command] : undefined;
  if (!entrypoint)
    throw new Error(
      `Usage: /profile [${Object.keys(profileCommandEntrypoints).join("|")}]`,
    );
  await entrypoint(commandArgs, ctx);
}
