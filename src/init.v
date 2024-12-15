module main

import service.db

fn init_db() ! {
	println('Initializing the database...')
	db.init()!
	println('Database initialized.')
}
