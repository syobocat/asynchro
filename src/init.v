module main

import conf
import model

fn init_db() ! {
	db := conf.data.db
	println('Initializing the database...')
	sql db {
		create table model.Entity
		create table model.Key
		create table model.SemanticID
		create table model.Profile
		create table model.Ack
	}!
	println('Database initialized.')
}
