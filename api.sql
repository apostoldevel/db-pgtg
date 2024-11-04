--------------------------------------------------------------------------------
-- TELEGRAM API ----------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- tg.fetch --------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.fetch (
  bot_id        uuid,
  resource      text,
  command       text,
  content       text,
  headers       jsonb DEFAULT null,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null,
  method        text DEFAULT 'POST'
) RETURNS       uuid
AS $$
DECLARE
  r             record;
  v_resource    text;
BEGIN
  SELECT token, username INTO r FROM tg.bot WHERE id = bot_id;

  IF FOUND THEN
    IF command = 'File' THEN
      v_resource := format('https://api.telegram.org/file/bot%s/%s', r.token, resource);
	ELSE
      v_resource := format('https://api.telegram.org/bot%s/%s', r.token, resource);
	END IF;

    RETURN http.create_request(v_resource, 'curl', method, headers, convert_to(content, 'utf8'), callback_done, callback_fail, null, 'telegram', r.username, command, message, data);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = http, pg_temp;

--------------------------------------------------------------------------------
-- tg.fetch JSON ---------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.fetch (
  bot_id        uuid,
  resource      text,
  command       text,
  content       jsonb,
  headers       jsonb DEFAULT null,
  callback_done text DEFAULT null,
  callback_fail text DEFAULT null,
  message       text DEFAULT null,
  data          jsonb DEFAULT null,
  method        text DEFAULT 'POST'
) RETURNS       uuid
AS $$
DECLARE
  r             record;
  v_resource    text;
BEGIN
  SELECT token, username INTO r FROM tg.bot WHERE id = bot_id;

  IF FOUND THEN
    IF headers IS NULL THEN
      headers := jsonb_build_object('Content-Type', 'application/json', 'Accept', 'application/json');
    END IF;

    IF command = 'File' THEN
      v_resource := format('https://api.telegram.org/file/bot%s/%s', r.token, resource);
	ELSE
      v_resource := format('https://api.telegram.org/bot%s/%s', r.token, resource);
	END IF;

    RETURN http.create_request(v_resource, 'curl', method, headers, convert_to(content::text, 'utf8'), callback_done, callback_fail, null, 'telegram', r.username, command, message, data);
  END IF;

  RETURN null;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = http, pg_temp;

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
  content       jsonb;
BEGIN
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

  RETURN tg.fetch(bot_id, 'sendMessage', 'sendMessage', content, null, callback_done, callback_fail, message, data);
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
  content       jsonb;
BEGIN
  content := jsonb_build_object('chat_id', chat_id, 'message_id', message_id);

  IF data IS NULL THEN
    data := json_build_object('bot_id', bot_id, 'chat_id', chat_id, 'message_id', message_id);
  END IF;

  RETURN tg.fetch(bot_id, 'deleteMessage', 'deleteMessage', content, null, callback_done, callback_fail, message, data);
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
  content       jsonb;
BEGIN
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

  RETURN tg.fetch(bot_id, 'editMessageText', 'editMessageText', content, null, callback_done, callback_fail, message, data);
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
  content       jsonb;
BEGIN
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

  RETURN tg.fetch(bot_id, 'sendDocument', 'sendDocument', content, null, callback_done, callback_fail, message, data);
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
  boundary      text;
  content       text;
BEGIN
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

  RETURN tg.fetch(bot_id, 'sendDocument', 'sendDocument', content, jsonb_build_object('Content-Type', format('multipart/form-data; boundary=%s', boundary)), callback_done, callback_fail, message, data);
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
  content       jsonb;
BEGIN
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

  RETURN tg.fetch(bot_id, 'answerCallbackQuery', 'answerCallbackQuery', content, null, callback_done, callback_fail, message, data);
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
BEGIN
  IF data IS NULL THEN
    data := json_build_object('bot_id', bot_id, 'file_id', file_id);
  END IF;

  RETURN tg.fetch(bot_id, 'getFile', 'getFile', jsonb_build_object('file_id', file_id), null, callback_done, callback_fail, message, data);
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
BEGIN
  IF message IS NULL THEN
    message := file_path;
  END IF;

  IF data IS NULL THEN
    data := json_build_object('bot_id', bot_id, 'file_id', file_id, 'file_path', file_path);
  END IF;

  RETURN tg.fetch(bot_id, file_path, 'File', null::text, null, callback_done, callback_fail, message, data, 'GET');
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;
