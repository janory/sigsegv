export interface AssetErroredPayload {
	type: string;
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
	test: boolean;
	status: string;
	mp4_support: string;
	max_resolution_tier: string;
	master_access: string;
	ingest_type: string;
	id: string;
	errors: Errors;
	encoding_tier: string;
	created_at: number;
}

export interface Errors {
	type: string;
	messages: string[];
}

export interface Environment {
	name: string;
	id: string;
}

export interface Object {
	type: string;
	id: string;
}
