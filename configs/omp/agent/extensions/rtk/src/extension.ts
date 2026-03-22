import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { detectRtk } from "./rtk-binary";
import { registerRtkCommands } from "./rtk-commands";
import { registerRtkRewrite } from "./rtk-rewrite";

function getExistingShellPrefix(): string | undefined {
	return process.env.PI_SHELL_PREFIX || process.env.CLAUDE_CODE_SHELL_PREFIX;
}

function enableShellPrefix(): { enabled: boolean; reason: string } {
	const existingPrefix = getExistingShellPrefix();
	if (existingPrefix) {
		return { enabled: false, reason: `shell prefix already set to ${existingPrefix}` };
	}

	process.env.PI_SHELL_PREFIX = "rtk";
	return { enabled: true, reason: "set PI_SHELL_PREFIX=rtk" };
}

export default async function rtkExtension(pi: ExtensionAPI) {
	pi.setLabel("RTK Token Optimizer");

	const rtk = await detectRtk(pi);
	registerRtkCommands(pi, rtk);

	if (!rtk.available || !rtk.version) {
		pi.logger.warn(`RTK unavailable; transparent compression disabled (${rtk.reason ?? "not installed"})`);
		pi.on("session_start", async (_event, ctx) => {
			ctx.ui.setStatus("rtk", "RTK unavailable");
		});
		return;
	}

	const prefixStatus = enableShellPrefix();
	registerRtkRewrite(pi);

	pi.logger.info(`RTK ${rtk.version} detected; ${prefixStatus.reason}`);
	pi.on("session_start", async (_event, ctx) => {
		const status = prefixStatus.enabled ? `RTK ${rtk.version}` : `RTK ${rtk.version} (rewrite fallback)`;
		ctx.ui.setStatus("rtk", status);
	});

	return {
		name: "omp-rtk-extension",
		description: "Transparent RTK compression for OMP bash commands.",
	};
}
