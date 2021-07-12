
--- Cleaner Settings
--
--  @topic settings


--- Enables unsafe methods.
--
--  `cleaner.remove_ore`
--
--  @setting cleaner.unsafe
--  @settype bool
--  @default false
cleaner.unsafe = core.settings:get_bool("cleaner.unsafe", false)
