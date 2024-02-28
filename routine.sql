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
  reply_markup  jsonb DEFAULT null,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null
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

    IF data IS NULL THEN
      data := json_build_object('bot_id', bot_id, 'chat_id', chat_id);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/sendMessage', v_token), 'native', 'POST', jsonb_build_object('Content-Type', 'application/json'), convert_to(content::text, 'utf8'), callback_done, callback_fail, 'telegram', bot_id::text, 'sendMessage', message, data);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#deleteMessage ----------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.delete_message (
  bot_id        uuid,
  chat_id       bigint,
  message_id    bigint,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
  content       jsonb;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    content := jsonb_build_object('chat_id', chat_id, 'message_id', message_id);

    IF data IS NULL THEN
      data := json_build_object('bot_id', bot_id, 'chat_id', chat_id, 'message_id', message_id);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/deleteMessage', v_token), 'native', 'POST', jsonb_build_object('Content-Type', 'application/json'), convert_to(content::text, 'utf8'), callback_done, callback_fail, 'telegram', bot_id::text, 'deleteMessage', message, data);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#editmessagetext --------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.edit_message_text (
  bot_id        uuid,
  chat_id       bigint,
  message_id    bigint,
  text          text,
  parse_mode    text DEFAULT null,
  reply_markup  jsonb DEFAULT null,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
  content       jsonb;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    content := jsonb_build_object('chat_id', chat_id, 'message_id', message_id, 'text', text);

    IF parse_mode IS NOT NULL THEN
	  content := content || jsonb_build_object('parse_mode', parse_mode);
	END IF;

    IF reply_markup IS NOT NULL THEN
	  content := content || jsonb_build_object('reply_markup', reply_markup);
	END IF;

    IF data IS NULL THEN
      data := json_build_object('bot_id', bot_id, 'chat_id', chat_id);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/editMessageText', v_token), 'native', 'POST', jsonb_build_object('Content-Type', 'application/json'), convert_to(content::text, 'utf8'), callback_done, callback_fail, 'telegram', bot_id::text, 'sendMessage', message, data);
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
  reply_markup  jsonb DEFAULT null,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null
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

    IF data IS NULL THEN
      data := json_build_object('bot_id', bot_id, 'chat_id', chat_id);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/sendDocument', v_token), 'native', 'POST', jsonb_build_object('Content-Type', 'application/json'), convert_to(content::text, 'utf8'), callback_done, callback_fail, 'telegram', bot_id::text, 'sendDocument', message, data);
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
  content_type  text DEFAULT null,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
  boundary      text;
  content       text;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    IF data IS NULL THEN
      data := json_build_object('bot_id', bot_id, 'chat_id', chat_id, 'file_name', file_name);
	END IF;

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

    RETURN http.create_request(format('https://api.telegram.org/bot%s/sendDocument', v_token), 'native', 'POST', jsonb_build_object('Content-Type', format('multipart/form-data; boundary=%s', boundary)), convert_to(content, 'utf8'), callback_done, callback_fail, 'telegram', bot_id::text, 'sendDocument', message, data);
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
  show_alert    bool DEFAULT null,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null
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

    IF data IS NULL THEN
      data := json_build_object('bot_id', bot_id, 'query_id', query_id);
	END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/answerCallbackQuery', v_token), 'native', 'POST', jsonb_build_object('Content-Type', 'application/json'), convert_to(content::text, 'utf8'), callback_done, callback_fail, 'telegram', bot_id::text, 'answerCallbackQuery', message, data);
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
  file_id       text,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    IF message IS NULL THEN
	  message := file_id;
    END IF;

    IF data IS NULL THEN
	  data := json_build_object('bot_id', bot_id, 'file_id', file_id);
    END IF;

    RETURN http.create_request(format('https://api.telegram.org/bot%s/getFile', v_token), 'native', 'POST', jsonb_build_object('Content-Type', 'application/json'), convert_to(jsonb_build_object('file_id', file_id)::text, 'utf8'), callback_done, callback_fail, 'telegram', bot_id::text, 'getFile', message, data);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- https://core.telegram.org/bots/api#file -------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.file_path (
  bot_id        uuid,
  file_id       text,
  file_path     text,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null
) RETURNS       uuid
AS $$
DECLARE
  v_token       text;
BEGIN
  SELECT token INTO v_token FROM bot.list WHERE id = bot_id;

  IF FOUND THEN
    IF message IS NULL THEN
	  message := file_id;
    END IF;

    IF data IS NULL THEN
	  data := json_build_object('bot_id', bot_id, 'file_id', file_id, 'file_path', file_path);
    END IF;

    RETURN http.create_request(format('https://api.telegram.org/file/bot%s/%s', v_token, file_path), 'native', 'GET', jsonb_build_object('Content-Type', 'application/json'), null, callback_done, callback_fail, 'telegram', bot_id::text, 'file_path', message, data);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;
