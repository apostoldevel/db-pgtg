--------------------------------------------------------------------------------
-- FUNCTION tg.bot_add ---------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.bot_add (
  pId           uuid,
  pToken        text,
  pUsername     text,
  pFullName     text,
  pWebhook      text,
  pSecret       text DEFAULT null,
  pLanguageCode text DEFAULT null
) RETURNS       uuid
AS $$
BEGIN
  INSERT INTO tg.bot (id, token, username, full_name, webhook, secret, language_code)
  VALUES (pId, pToken, pUsername, pFullName, pWebhook, pSecret, coalesce(pLanguageCode, 'en'))
  RETURNING id INTO pId;

  RETURN pId;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION tg.bot_update ------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.bot_update (
  pId           uuid,
  pToken        text DEFAULT NULL,
  pUsername     text DEFAULT NULL,
  pFullName     text DEFAULT NULL,
  pWebhook      text DEFAULT NULL,
  pSecret       text DEFAULT NULL,
  pLanguageCode text DEFAULT NULL
) RETURNS       bool
AS $$
BEGIN
  UPDATE tg.bot
     SET token = coalesce(pToken, token),
         username = coalesce(pUsername, username),
         full_name = coalesce(pFullName, full_name),
         webhook = coalesce(pWebhook, webhook),
         secret = nullif(coalesce(pSecret, secret, ''), ''),
         language_code = coalesce(pLanguageCode, language_code)
   WHERE id = pId;

  RETURN FOUND;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION tg.bot_set ---------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.bot_set (
  pId           uuid,
  pToken        text DEFAULT NULL,
  pUsername     text DEFAULT NULL,
  pFullName     text DEFAULT NULL,
  pWebhook      text DEFAULT NULL,
  pSecret       text DEFAULT NULL,
  pLanguageCode text DEFAULT NULL
) RETURNS       uuid
AS $$
BEGIN
  PERFORM FROM tg.bot WHERE id = pId;

  IF FOUND THEN
    PERFORM tg.bot_update(pId, pToken, pUsername, pFullName, pWebhook, pSecret, pLanguageCode);
  ELSE
    pId := tg.bot_add(pId, pToken, pUsername, pFullName, pWebhook, pSecret, pLanguageCode);
  END IF;

  RETURN pId;
END;
$$ LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = tg, pg_temp;

--------------------------------------------------------------------------------
-- FUNCTION tg.bot_delete ------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tg.bot_delete (
  pId       uuid
) RETURNS   bool
AS $$
BEGIN
  DELETE FROM tg.bot WHERE id = pId;
  RETURN FOUND;
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = tg, pg_temp;
