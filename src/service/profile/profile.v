module profile

import model
import database
import entity
import util

pub fn lookup(sid string, owner string) !database.DBResult[model.Profile] {
	profile_owner := if util.is_ccid(owner) {
		owner
	} else {
		ent := entity.get_by_alias(owner)!
		ent.id
	}
	return database.get_opt[model.Profile](id: sid, owner: profile_owner)
}
