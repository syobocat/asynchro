module database

import log
import conf

pub struct KV implements Insertable {
pub:
	owner string @[unique: 'keyowner']
	key   string @[unique: 'keyowner']
	value string
}

fn (kv KV) exists() !bool {
	return exists[KV](id: kv.key, owner: kv.owner)!
}

fn (kv KV) insert() ! {
	db := conf.data.db
	sql db {
		insert kv into KV
	}!
	log.info('[DB] KV ${kv.key} created for user ${kv.owner}')
}

fn (kv KV) update() ! {
	db := conf.data.db
	sql db {
		update KV set value = kv.value where key == kv.key && owner == kv.owner
	}!
	log.info('[DB] KV ${kv.key} updated for user ${kv.owner}')
}
