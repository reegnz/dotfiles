import type { AnyModel } from "@earendil-works/pi-ai";
import { getBuiltinModels } from "@earendil-works/pi-ai/providers/all";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const GPT_RESPONSES = /^gpt-?(5\.6|6)([.-]|$)/i;
const CLAUDE = /^claude(?:$|[-._])/i;
const OPENAI_MODELS = new Map(getBuiltinModels("openai").map(model => [model.id, model]));

function patchModel<T extends AnyModel>(model: T): T {
  if (model.provider !== "litellm") return model;
  if (model.type && model.type !== "chat") return model;
  if (GPT_RESPONSES.test(model.id)) {
    const catalog = OPENAI_MODELS.get(model.id.toLowerCase().replace(/^gpt-?/, "gpt-"));
    if (!catalog) return model;
    return {
      ...model,
      api: catalog.api,
      reasoning: catalog.reasoning,
      thinkingLevelMap: catalog.thinkingLevelMap,
    };
  }
  if (CLAUDE.test(model.id) && model.api !== "anthropic-messages") return {
    ...model,
    api: "anthropic-messages"
  };
  return model;
}

export default function (pi: ExtensionAPI) {
  let installed = false;
  pi.on("session_start", (_event, ctx) => {
    if (installed) return;
    const upstream = ctx.modelRegistry.getRegisteredNativeProvider("litellm");
    if (!upstream) {
      ctx.ui.notify("Could not install LiteLLM protocol overrides: native provider not found", "warning");
      return;
    }
    pi.registerProvider({
      ...upstream,
      getModels: () => upstream.getModels().map(patchModel),
      // Pi's registry prefers getAllModels(), including image and classifier models.
      getAllModels: () => (upstream.getAllModels?.() ?? upstream.getModels()).map(patchModel),
    });
    installed = true;
  });
}
