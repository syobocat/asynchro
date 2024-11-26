module conf

import json
import db.sqlite
import os

pub struct Config {
pub:
	host    string @[required]
	name    string = 'Asynchro'
	desc    string = 'Yet Another Concrnt'
	bind    string = '0.0.0.0'
	port    int    = 3000
	db_path string = 'database.db'
}

pub struct Data {
	Config
pub:
	db sqlite.DB @[required]
}

pub const data = read_config()

fn read_config() Data {
	config_path := os.getenv_opt('ASYNCHRO_CONFIG') or { $d('config_path', 'config.json') }
	config_json := os.read_file(config_path) or { panic('Failed to read config file: ${err}') }
	config := json.decode(Config, config_json) or { panic('Failed to parse config file: ${err}') }

	db := sqlite.connect(config.db_path) or { panic('Failed to connect to the database: ${err}') }
	db.synchronization_mode(.normal) or { panic(err) }
	db.journal_mode(.truncate) or { panic(err) }

	return Data{
		Config: config
		db:     db
	}
}
