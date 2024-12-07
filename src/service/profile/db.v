module profile

import conf
import model
import service.ccid
import service.entity
import service.semantic_id

pub fn get(id string) !model.DBResult[model.Profile] {
	db := conf.data.db

	profiles := sql db {
		select from model.Profile where id == id
	}!

	return model.DBResult{
		result: profiles[0] or { none }
	}
}

pub fn get_by_semantic_id(sid string, owner string) !model.DBResult[model.Profile] {
	id := if ccid.is_ccid(owner) {
		ent := entity.get_by_alias(owner)!

		semantic_id.lookup(sid, ent.ccid)!
	} else {
		semantic_id.lookup(sid, owner)!
	}

	return get(id)
}
