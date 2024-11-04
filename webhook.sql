--------------------------------------------------------------------------------
-- TELEGRAM BOT WEBHOOK --------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.webhook (
  pName         text,
  pBody         jsonb
) RETURNS       bool
AS $$
DECLARE
  r             record;

  result        bool DEFAULT false;

  vSchema       text;
  vName         text;
  vMessage      text;
  vContext      text;
BEGIN
  FOR r IN SELECT id, webhook FROM tg.bot WHERE username = pName
  LOOP
    vSchema := split_part(r.webhook, '.', 1);
    vName := split_part(r.webhook, '.', 2);

    PERFORM FROM pg_namespace n INNER JOIN pg_proc p ON n.oid = p.pronamespace WHERE n.nspname = vSchema AND p.proname = vName;
    IF FOUND THEN
      EXECUTE format('SELECT %s.%I($1, $2);', vSchema, vName) INTO result USING r.id, pBody;
    END IF;
  END LOOP;

  RETURN result;
EXCEPTION
WHEN others THEN
  GET STACKED DIAGNOSTICS vMessage = MESSAGE_TEXT, vContext = PG_EXCEPTION_CONTEXT;
  PERFORM WriteDiagnostics(vMessage, vContext);
  RETURN false;
END
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = kernel, pg_temp;
