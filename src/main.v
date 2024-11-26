module main

import cli
import os
import server

fn main() {
	mut app := cli.Command{
		name:       'asynchro'
		posix_mode: true
		execute:    fn (cmd cli.Command) ! {
			server.serve()
			return
		}
	}
	app.setup()
	app.parse(os.args)
}
