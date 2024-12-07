module semantic_id

import conf
import model

// V does not support Result of Option
pub fn get(id string, owner string) !model.DBResult[model.SemanticID] {
	db := conf.data.db

	ids := sql db {
		select from model.SemanticID where id == id && owner == owner
	}!

	return model.DBResult[model.SemanticID]{
		result: if sid := ids[0] { sid } else { none }
	}
}

pub fn lookup(id string, owner string) !string {
	res := get(id, owner)!
	sid := res.result or { return error('not found') }
	return sid.target
}
