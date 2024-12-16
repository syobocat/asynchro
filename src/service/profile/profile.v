module profile

import model
import service.db
import service.entity
import util

pub fn lookup(sid string, owner string) !db.DBResult[model.Profile] {
	res := if !util.is_ccid(owner) {
		ent := entity.get_by_alias(owner)!

		db.resolve_semanticid(sid, ent.id)!
	} else {
		db.resolve_semanticid(sid, owner)!
	}

	if id := res.result {
		return db.get[model.Profile](id: id)
	} else {
		return db.DBResult[model.Profile]{
			result: none
		}
	}
}
