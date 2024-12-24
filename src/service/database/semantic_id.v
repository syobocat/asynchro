module database

import time
import conf

pub struct SemanticID implements Insertable {
pub:
	id        string @[unique: 'idowner']
	owner     string @[unique: 'idowner']
	target    string
	document  string
	signature string
	cdate     time.Time
	mdate     time.Time
}

fn (sid SemanticID) exists() !bool {
	res := get_opt[SemanticID](id: sid.id, owner: sid.owner)!
	return !(res.result == none)
}

fn (sid SemanticID) insert() ! {
	db := conf.data.db
	sql db {
		insert sid into SemanticID
	}!
}

fn (sid SemanticID) update() ! {
	db := conf.data.db
	sql db {
		update SemanticID set target = sid.target, document = sid.document, signature = sid.signature,
		mdate = time.utc() where id == sid.id && owner == sid.owner
	}!
}

pub fn (sid SemanticID) delete() ! {
	db := conf.data.db
	sql db {
		delete from SemanticID where id == sid.id && owner == sid.owner
	}!
}

pub fn delete_semanticid(id string, owner string) ! {
	res := get_opt[SemanticID](id: id, owner: owner)!
	if sid := res.result {
		sid.delete()!
	}
}

pub fn resolve_semanticid(id string, owner string) !DBResult[string] {
	res := get_opt[SemanticID](id: id, owner: owner)!
	if sid := res.result {
		return wrap_result([sid.target])
	} else {
		return wrap_result[string]([])
	}
}
