import { Mux } from "npm:@mux/mux-node";
import { mux } from "../shared/mux.ts";
import { supabase } from "../shared/supabase.ts";

type Payload = Mux.VideoAssetReadyWebhookEvent | Mux.VideoAssetErroredWebhookEvent;

Deno.serve(async (req) => {
	const data = (await req.json()) as Payload;

	try {
		mux.webhooks.verifySignature(JSON.stringify(data), req.headers);
	} catch (error) {
		console.error("Failed to verify signature", error);
		return new Response("Unauthorized", { status: 401 });
	}

	if (data.type === "video.asset.ready") {
		const asset = await supabase
			.from("mux_assets")
			.select("*")
			.eq("asset_id", data.object.id)
			.single();

		if (asset.data) {
			await supabase
				.from("mux_assets")
				.update({ asset_ready: true, duration_seconds: data.data.duration })
				.eq("asset_id", data.object.id);
		}
	}

	if (data.type === "video.asset.errored") {
		const errorMessages = data.data.errors?.messages?.join(", ");
		if (errorMessages) {
			await supabase
				.from("mux_assets")
				.update({ upload_message: errorMessages })
				.eq("asset_id", data.object.id);
		}
	}

	return new Response(JSON.stringify({ message: "OK" }), {
		headers: { "Content-Type": "application/json" }
	});
});
