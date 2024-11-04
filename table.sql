--------------------------------------------------------------------------------
-- BOT -------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- tg.bot ----------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE TABLE tg.bot (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token         text NOT NULL,
  username      text NOT NULL,
  full_name     text NOT NULL,
  webhook       text NOT NULL,
  secret        text,
  language_code text DEFAULT 'en',
  created       timestamptz NOT NULL DEFAULT Now()
);

COMMENT ON TABLE tg.bot IS 'Telegram bot.';

COMMENT ON COLUMN tg.bot.id IS 'Identifier';
COMMENT ON COLUMN tg.bot.token IS 'Token';
COMMENT ON COLUMN tg.bot.username IS 'Bot username';
COMMENT ON COLUMN tg.bot.full_name IS 'Bot name';
COMMENT ON COLUMN tg.bot.webhook IS 'Webhook function';
COMMENT ON COLUMN tg.bot.secret IS 'Secret code for authorization (if necessary).';
COMMENT ON COLUMN tg.bot.language_code IS 'Language code';
COMMENT ON COLUMN tg.bot.created IS 'Date and time of creation';

CREATE UNIQUE INDEX ON tg.bot (username);
