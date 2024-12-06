module main

import cli
import os
import conf
import server
import service.key

fn main() {
	mut app := cli.Command{
		name:       'asynchro'
		posix_mode: true
		flags:      [cli.Flag{
			flag: .bool
			name: 'uwu'
		}]
		execute:    fn (cmd cli.Command) ! {
			if conf.data.initialized {
				server.serve(cmd.flags[0].get_bool()!)
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
					privkey_hex := key.generate_privkey_hex()!
					println('"privkey": "${privkey_hex}",')
					return
				}
			},
		]
	}
	app.setup()
	app.parse(os.args)
}
