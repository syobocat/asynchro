module profile

import model
import service.db
import service.entity
import util

pub fn lookup(sid string, owner string) !db.DBResult[model.Profile] {
	profile_owner := if util.is_ccid(owner) {
		owner
	} else {
		ent := entity.get_by_alias(owner)!
		ent.id
	}
	return db.get[model.Profile](id: sid, owner: profile_owner)
}
