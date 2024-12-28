module main

import cli
import log
import os
import conf
import server
import service.ccid

fn main() {
	log_level := match os.getenv('ASYNCHRO_LOG').to_lower_ascii() {
		'debug' {
			log.Level.debug
		}
		'warn' {
			log.Level.warn
		}
		'error' {
			log.Level.error
		}
		'fatal' {
			log.Level.fatal
		}
		'disable' {
			log.Level.disabled
		}
		else {
			log.Level.info
		}
	}
	mut logger := log.new_thread_safe_log()
	logger.set_level(log_level)
	logger.set_time_format(.tf_ss)
	log.set_logger(logger)

	mut app := cli.Command{
		name:       'asynchro'
		posix_mode: true
		flags:      [cli.Flag{
			flag: .bool
			name: 'uwu'
		}]
		execute:    fn (cmd cli.Command) ! {
			if conf.data.initialized {
				server.serve(cmd.flags[0].get_bool()!)!
			} else {
				eprintln('Failed to read config: ${conf.data.error or { 'Unknown error' }}')
			}
			return
		}
		commands:   [
			cli.Command{
				name:    'init'
				execute: fn (cmd cli.Command) ! {
					init_db()!
					return
				}
			},
			cli.Command{
				name:    'keygen'
				execute: fn (cmd cli.Command) ! {
					privkey_hex := ccid.generate_privkey_hex()!
					println('"privkey": "${privkey_hex}",')
					return
				}
			},
		]
	}
	app.setup()
	app.parse(os.args)
}
