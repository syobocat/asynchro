module conf

import json
import db.sqlite
import os
import time
import v.vmod

pub struct Config {
pub:
	host      string @[required]
	bind      string = '0.0.0.0'
	port      int    = 3000
	dimension string = 'concrnt-devnet'
	db_path   string = 'database.db'
	privkey   string   @[required]
	metadata  Metadata @[required]
}

pub enum RegistrationState {
	open
	invite
	close
}

pub struct Metadata {
pub:
	nickname         string = 'Asynchro'
	description      string = 'Yet Another Concrnt'
	logo             string
	wordmark         string
	theme_color      string            @[json: 'themeColor']
	maintainer_name  string            @[json: 'maintainerName']
	maintainer_email string            @[json: 'maintainerEmail']
	registration     RegistrationState @[required]
	version          string
	asynchro_version string @[json: 'AsynchroVersion']
	build_info struct {
		build_time string @[json: 'BuildTime']
		build_machine string @[json: 'BuildMachine']
		go_version string @[json: 'GoVersion']
		asynchro_build_time string @[json: 'AsynchroBuildTime']
		v_version string @[json: 'VVersion']
	} @[json: 'buildInfo']
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
	config_loaded := json.decode(Config, config_json) or {
		panic('Failed to parse config file: ${err}')
	}

	// Overwrite
	manifest := vmod.decode(@VMOD_FILE) or { panic(err) }
	build_time := time.unix(@BUILD_TIMESTAMP.i64())
	config := Config{
		...config_loaded
		metadata: Metadata{
			...config_loaded.metadata
			asynchro_version: 'v${manifest.version}'
			version: 'unknown'
			build_info: struct {
				build_time: 'unknown'
				build_machine: 'unknown'
				go_version: 'unknown'
				asynchro_build_time: '${build_time.custom_format("ddd MMM DD HH:mm:ss UTC YYYY")}'
				v_version: @VHASH
				}
		}
	}

	db := sqlite.connect(config.db_path) or { panic('Failed to connect to the database: ${err}') }
	db.synchronization_mode(.normal) or { panic(err) }
	db.journal_mode(.truncate) or { panic(err) }

	return Data{
		Config: config
		db:     db
	}
}
