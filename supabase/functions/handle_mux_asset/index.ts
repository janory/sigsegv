import { Database } from "supabase-types";
import { mux } from "../shared/mux.ts";
import { supabase } from "../shared/supabase.ts";
import { isLocal } from "../shared/is-local.ts";

type Row = Database["public"]["Tables"]["mux_assets"]["Row"];

interface BasePayload {
	type: "INSERT" | "DELETE";
	schema: "public";
	table: "mux_videos";
}

interface InsertPayload extends BasePayload {
	type: "INSERT";
	record: Row;
	old_record: null;
}

interface UpdatePayload extends BasePayload {
	type: "DELETE";
	record: null;
	old_record: Row;
}

type Payload = InsertPayload | UpdatePayload;

Deno.serve(async (req) => {
	const token = req.headers.get("x-function-token");
	const compareToken = Deno.env.get("FUNCTION_TOKEN");

	if (!isLocal) {
		if (!compareToken) {
			console.error("'FUNCTION_TOKEN' is not set in the environment variables.");
			return new Response(JSON.stringify({ message: "Unauthorized" }), {
				status: 401,
				headers: { "Content-Type": "application/json" }
			});
		}

		if (token !== compareToken) {
			return new Response(JSON.stringify({ message: "Unauthorized" }), {
				status: 401,
				headers: { "Content-Type": "application/json" }
			});
		}
	}

	const body: Payload = await req.json();

	if (body.type === "INSERT") {
		const { data, error } = await supabase
			.schema("storage")
			.from("objects")
			.select("*")
			.eq("id", body.record.video_upload_id)
			.single();

		if (error) {
			console.log("Failed to get object", error);
			throw new Error(error.message);
		}

		const path = data?.path_tokens || ([] as string[]);
		const url = await supabase.storage.from("video_uploads").createSignedUrl(path.join("/"), 60);

		if (url.error) {
			console.log("Failed to get signed url", url.error);
			throw new Error(url.error.message);
		}

		const assetUrl = new URL(url.data.signedUrl);

		if (assetUrl.host.includes("kong")) {
			assetUrl.host = "60b4-51-175-94-240.ngrok-free.app";
			assetUrl.protocol = "https";
			assetUrl.port = "";
		}

		const asset = await mux.video.assets.create({
			playback_policy: [body.record.playback_policy],
			test: isLocal,
			input: [
				{
					url: assetUrl.toString()
				}
			]
		});

		if (asset.errors) {
			console.error("Failed to create asset", asset.errors);
			throw new Error(asset.errors.messages?.join(", "));
		}

		const playbackId = asset.playback_ids?.at(0)?.id;

		await supabase
			.from("mux_assets")
			.update({ playback_id: playbackId, asset_id: asset.id })
			.eq("id", body.record.id);
	} else if (body.type === "DELETE") {
		if (body.old_record.asset_id) {
			await mux.video.assets.delete(body.old_record.asset_id);
		}
	}

	return new Response(JSON.stringify({ message: "OK" }), {
		headers: { "Content-Type": "application/json" }
	});
});
