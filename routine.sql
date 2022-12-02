--------------------------------------------------------------------------------
-- TELEGRAM API ----------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#sendmessage ------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.send_message (
  bot_id        uuid,
  chat_id       bigint,
  text          text,
  parse_mode    text DEFAULT null,
  reply_markup  jsonb DEFAULT null
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

    IF reply_markup IS NOT NULL THEN
	  content := content || jsonb_build_object('reply_markup', reply_markup);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/sendMessage', v_token), 'POST', jsonb_build_object('Content-Type', 'application/json'), content::text, null, null, 'telegram', bot_id::text, 'sendMessage');
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#senddocument -----------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.send_document (
  bot_id        uuid,
  chat_id       bigint,
  document      text,
  parse_mode    text DEFAULT null,
  reply_markup  jsonb DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
  content       jsonb;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    content := jsonb_build_object('chat_id', chat_id, 'document', document);

    IF parse_mode IS NOT NULL THEN
	  content := content || jsonb_build_object('parse_mode', parse_mode);
	END IF;

    IF reply_markup IS NOT NULL THEN
	  content := content || jsonb_build_object('reply_markup', reply_markup);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/sendDocument', v_token), 'POST', jsonb_build_object('Content-Type', 'application/json'), content::text, null, null, 'telegram', bot_id::text, 'sendDocument');
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#senddocument -----------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.send_document_multipart (
  bot_id        uuid,
  chat_id       bigint,
  file_name     text,
  file_body     text,
  content_type  text DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
  boundary      text;
  content       text;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    content_type := coalesce(content_type, 'text/plain');

    boundary := gen_random_uuid()::text;

    content := format(E'--%s\r\n', boundary);
    content := concat(content, E'Content-Disposition: form-data; name="chat_id"\r\n\r\n');
    content := concat(content, format(E'%s\r\n', chat_id));
    content := concat(content, format(E'--%s\r\n', boundary));
    content := concat(content, format(E'Content-Disposition: form-data; name="document"; filename="%s"\r\n', file_name));
    content := concat(content, format(E'Content-Type: %s\r\n\r\n', content_type));

    content := concat(content, file_body);

    content := concat(content, format(E'\r\n\r\n--%s--', boundary));

    RETURN http.create_request(format('https://api.telegram.org/bot%s/sendDocument', v_token), 'POST', jsonb_build_object('Content-Type', format('multipart/form-data; boundary=%s', boundary)), content, null, null, 'telegram', bot_id::text, 'sendDocument');
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#answercallbackquery ----------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.answer_callback_query (
  bot_id        uuid,
  query_id      text,
  text          text DEFAULT null,
  show_alert    bool DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
  content       jsonb;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    content := jsonb_build_object('callback_query_id', query_id);

    IF text IS NOT NULL THEN
	  content := content || jsonb_build_object('text', text);
	END IF;

    IF show_alert IS NOT NULL THEN
	  content := content || jsonb_build_object('show_alert', show_alert);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/answerCallbackQuery', v_token), 'POST', jsonb_build_object('Content-Type', 'application/json'), content::text, null, null, 'telegram', bot_id::text, 'answerCallbackQuery');
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
    RETURN http.create_request(format('https://api.telegram.org/bot%s/getFile', v_token), 'POST', jsonb_build_object('Content-Type', 'application/json'), jsonb_build_object('file_id', file_id)::text, 'bot.get_file_done', 'bot.get_file_fail', 'telegram', bot_id::text, 'getFile');
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#getfile ----------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.file_path (
  bot_id        uuid,
  file_id       text,
  file_path     text
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    RETURN http.create_request(format('https://api.telegram.org/file/bot%s/%s', v_token, file_path), 'GET', jsonb_build_object('Content-Type', 'application/json'), null, 'bot.get_file_done', 'bot.get_file_fail', 'telegram', bot_id::text, 'file_path', file_id);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;
