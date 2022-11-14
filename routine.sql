--------------------------------------------------------------------------------
-- TELEGRAM API ----------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#sendmessage ------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.send_message (
  bot_id        uuid,
  chat_id       int,
  text          text,
  parse_mode    text DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
  content       jsonb;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    content := jsonb_build_object('chat_id', chat_id, 'text', text);

    IF parse_mode IS NOT NULL THEN
	  content := content || jsonb_build_object('parse_mode', parse_mode);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/sendMessage', v_token), 'POST', null, content::text);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#getfile ----------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.get_file (
  bot_id        uuid,
  file_id       text
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    RETURN http.create_request(format('https://api.telegram.org/bot%s/getFile', v_token), 'POST', null, jsonb_build_object('file_id', file_id)::text, 'bot.get_file_done', 'bot.get_file_fail', 'telegram', bot_id::text, 'getFile');
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;
