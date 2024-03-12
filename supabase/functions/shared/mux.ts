import Mux from "npm:@mux/mux-node";

export const mux = new Mux({
	tokenId: Deno.env.get("MUX_ACCESS_TOKEN_ID") || "",
	tokenSecret: Deno.env.get("MUX_SECRET_KEY") || "",
	webhookSecret: Deno.env.get("MUX_WEBHOOK_SECRET") || ""
});
