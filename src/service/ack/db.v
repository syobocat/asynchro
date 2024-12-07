module ack

import conf
import model

pub fn get_acking(key string) ![]model.Ack {
	db := conf.data.db

	acks := sql db {
		select from model.Ack where from == key && valid == true
	}!

	return acks
}

pub fn get_acker(key string) ![]model.Ack {
	db := conf.data.db

	acks := sql db {
		select from model.Ack where to == key && valid == true
	}!

	return acks
}
