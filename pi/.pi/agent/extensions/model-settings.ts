/**
 * Model Settings Extension
 *
 * Displays the currently selected model configuration as a JSON dump.
 * Shows all model properties including provider, context window, cost, capabilities, etc.
 *
 * Usage: /model-settings
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {

	pi.registerCommand("model-settings", {
		description: "Show current model settings",
		handler: async (_args, ctx) => {
			const model = ctx.model;
			if (!model) {
				ctx.ui.notify("No model selected", "error");
				return;
			}

			// Format the model object as JSON for display
			const modelSettings = {
				// BaseModel
				id: model.id,
				name: model.name,
				api: model.api,
				provider: model.provider,
				baseUrl: model.baseUrl,
				input: model.input,
				inputLimits: model.inputLimits,
				cost: {
					tiers: model.cost.tiers,
					input: model.cost.input,
					output: model.cost.output,
					cacheRead: model.cost.cacheRead,
					cacheWrite: model.cost.cacheWrite,
				},
				headers: model.headers,
				// Model
				type: model.type,
				reasoning: model.reasoning,
				thinkingLevelMap: model.thinkingLevelMap,
				promptCache: model.promptCache,
				contextWindow: model.contextWindow,
				maxTokens: model.maxTokens,
				samplingParams: model.samplingParams,
				compat: model.compat,
			};

			const jsonStr = JSON.stringify(modelSettings, null, 2);

			// Notify with the full JSON
			ctx.ui.notify(`Model Settings:\n\n${jsonStr}`, "info");
		},
	});
}
