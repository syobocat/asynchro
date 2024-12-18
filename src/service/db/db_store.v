module db

import conf
import model

pub fn store_new(record Insertable) ! {
	db := conf.data.db

	match record {
		model.Entity {
			entity := record as model.Entity
			sql db {
				insert entity into model.Entity
			}!
		}
		else {
			return error('Not implemented')
		}
	}
}

pub fn store(record Insertable) ! {
	match record {
		model.Entity { return store_entity(record) }
		else { return error('Not implemented') }
	}
}
