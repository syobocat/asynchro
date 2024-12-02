module main

import cli
import os
import server
import service.ccid

fn main() {
	mut app := cli.Command{
		name:       'asynchro'
		posix_mode: true
		execute:    fn (cmd cli.Command) ! {
			server.serve()
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
