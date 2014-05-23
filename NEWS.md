# Change history for the MySQL sys schema

## 1.0.1

### Improvements

* Added procedures to enable / disable Performance Schema consumers. (Contributed by the MySQL QA Team)
** `ps_setup_disable_consumers(<LIKE string>)` allows disabling any consumers matching the LIKE string.
** `ps_setup_enable_consumers(<LIKE string>)` allows enabling any consumers matching the LIKE string.

* Added procedures to show both enabled and disbled consumers or instruments individually, these are more useful for tooling than the `ps_setup_show_enabled`/`ps_setup_show_disabled` procedures which show all configuration in multiple result sets.  (Contributed by the MySQL QA Team)
** `ps_setup_show_disabled_consumers` shows only disabled consumers.
** `ps_setup_show_disabled_instruments` shows only disabled instruments.
** `ps_setup_show_enabled_consumers` shows only enabled consumers.
** `ps_setup_show_enabled_instruments` shows only enabled instruments.

### Bug Fixes

* Running the installation scripts sometimes failed because of the comment format. (#1) (Contributed by Joe Grasse)
* Some views did not work with the ERROR_FOR_DIVISION_BY_ZERO SQL mode. (#6) (Contributed by Joe Grasse)
* On Windows the `ps_thread_stack()` stored function failed to escape file path backslashes correctly within the JSON output.

## 1.0.0 (11/04/2004)