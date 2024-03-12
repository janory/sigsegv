export const isLocal = Deno.env.get("SUPABASE_URL")?.startsWith("http://");
