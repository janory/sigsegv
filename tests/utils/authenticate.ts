import type { BrowserContext, Page } from "playwright";
import { getSession } from "./get-session";

export async function authenticate(context: BrowserContext) {
	const session = await getSession();
	await context.addCookies([
		{
			name: "sb-127-auth-token",
			value: encodeURI(JSON.stringify(session)),
			path: "/",
			domain: "localhost"
		}
	]);
}
