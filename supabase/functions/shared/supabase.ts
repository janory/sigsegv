import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";
import { Database } from "supabase-types";

export const supabase = createClient<Database>(
	Deno.env.get("SUPABASE_URL") || "",
	Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || ""
);
