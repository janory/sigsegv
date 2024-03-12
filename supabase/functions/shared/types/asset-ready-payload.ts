export interface AssetReadyPayload {
	type: "video.asset.ready";
	request_id: null;
	object: Object;
	id: string;
	environment: Environment;
	data: Data;
	created_at: string;
	attempts: Attempt[];
	accessor_source: null;
	accessor: null;
}

export interface Attempt {
	webhook_id: number;
	response_status_code: number;
	response_headers: ResponseHeaders;
	response_body: string;
	max_attempts: number;
	id: string;
	created_at: string;
	address: string;
}

export interface ResponseHeaders {
	"ngrok-trace-id": string;
	"ngrok-error-code": string;
	date: string;
	"content-type": string;
	"content-length": string;
	connection: string;
}

export interface Data {
	tracks: Track[];
	test: boolean;
	status: string;
	resolution_tier: string;
	playback_ids: PlaybackID[];
	mp4_support: string;
	max_stored_resolution: string;
	max_stored_frame_rate: number;
	max_resolution_tier: string;
	master_access: string;
	ingest_type: string;
	id: string;
	encoding_tier: string;
	duration: number;
	created_at: number;
	aspect_ratio: string;
}

export interface PlaybackID {
	policy: string;
	id: string;
}

export interface Track {
	type: string;
	primary?: boolean;
	max_channels?: number;
	max_channel_layout?: string;
	id: string;
	duration: number;
	max_width?: number;
	max_height?: number;
	max_frame_rate?: number;
}

export interface Environment {
	name: string;
	id: string;
}

export interface Object {
	type: string;
	id: string;
}
