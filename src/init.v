module main

import database

fn init_db() ! {
	println('Initializing the database...')
	database.init_db()!
	println('Database initialized.')
}
