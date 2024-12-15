module db

import time
import conf
import model

fn store_entity(entity model.Entity) ! {
	res := get_by_id[model.Entity](entity.id)!
	if res.result == none {
		store_new(entity)!
	} else {
		db := conf.data.db
		sql db {
			update model.Entity set domain = entity.domain, affiliation_document = entity.affiliation_document,
			affiliation_signature = entity.affiliation_signature, mdate = time.utc() where id == entity.id
		}!
	}
}

pub fn set_alias(id string, alias string) ! {
	db := conf.data.db

	sql db {
		update model.Entity set alias = alias where id == id
	}!
}
