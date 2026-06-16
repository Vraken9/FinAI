import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  const { data: { user }, error: authError } = await supabase.auth.getUser(
    authHeader?.replace("Bearer ", "") ?? ""
  );
  if (authError || !user) {
    return new Response(JSON.stringify({ success: false, error: "Unauthorized", code: "UNAUTHORIZED" }), 
      { status: 401 });
  }

  const { title, body, data, target_user_id } = await req.json().catch(() => ({}));

  // Mock implementation for FCM
  const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");
  if (!fcmServerKey) {
    return new Response(JSON.stringify({ success: false, error: "FCM_SERVER_KEY not configured", code: "SERVER_ERROR" }), { status: 500 });
  }

  return new Response(JSON.stringify({
    success: true,
    message: "Notification sent (mock)"
  }), { headers: { "Content-Type": "application/json" } });
});
