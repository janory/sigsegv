import { TEST_USER } from "../consts";
import { createSupabaseClient } from "./create-supabase-client";

export async function getSession() {
	const supabase = createSupabaseClient();

	const { data, error } = await supabase.auth.signInWithPassword({
		email: TEST_USER.email,
		password: TEST_USER.password
	});

	if (error) {
		throw error;
	}

	return data.session;
}
