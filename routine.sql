--------------------------------------------------------------------------------
-- TELEGRAM API ----------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.send_message (
  bot_id    uuid,
  chat_id   int,
  text      text
) RETURNS   uuid
AS $$
DECLARE
  v_token   text;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    RETURN http.create_request(format('https://api.telegram.org/bot%s/sendMessage', v_token), 'POST', null, json_build_object('chat_id', chat_id, 'text', text)::text);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;
