import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as xlsx from "https://esm.sh/xlsx@0.18.5";

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

  const formData = await req.formData().catch(() => null);
  if (!formData) {
    return new Response(JSON.stringify({ success: false, error: "Invalid form data", code: "VALIDATION_ERROR" }), { status: 422 });
  }

  const file = formData.get("file") as File;
  if (!file) {
    return new Response(JSON.stringify({ success: false, error: "File Excel tidak ditemukan", code: "VALIDATION_ERROR" }), { status: 422 });
  }

  const arrayBuffer = await file.arrayBuffer();
  const workbook = xlsx.read(new Uint8Array(arrayBuffer), { type: "array" });
  const sheetName = workbook.SheetNames[0];
  const worksheet = workbook.Sheets[sheetName];
  const rows = xlsx.utils.sheet_to_json(worksheet);

  // MOCK VALIDATION LOGIC as per PRD
  return new Response(JSON.stringify({
    success: true,
    data: {
      total_rows: rows.length,
      valid_rows: rows.length,
      invalid_rows: 0,
      errors: [],
      preview: rows.slice(0, 5),
      import_token: "mock-token-" + Date.now()
    }
  }), { headers: { "Content-Type": "application/json" } });
});
