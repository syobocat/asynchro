module database

import log
import time
import conf

pub struct SemanticID implements ImutInsertable {
pub:
	id        string @[unique: 'idowner']
	owner     string @[unique: 'idowner']
	target    string
	document  string
	signature string
	cdate     time.Time
	mdate     time.Time
}

@[inline]
fn (_ SemanticID) imut() {}

fn (sid SemanticID) exists() !bool {
	return exists[SemanticID](id: sid.id, owner: sid.owner)!
}

fn (sid SemanticID) insert() ! {
	db := conf.data.db
	sql db {
		insert sid into SemanticID
	}!

	log.info('[DB] SemanticID ${sid.id} issued for user ${sid.owner}')
}

fn (sid SemanticID) update() ! {
	db := conf.data.db
	sql db {
		update SemanticID set target = sid.target, document = sid.document, signature = sid.signature,
		mdate = time.utc() where id == sid.id && owner == sid.owner
	}!
	log.info('[DB] SemanticID ${sid.id} updated for user ${sid.owner}')
}

pub fn (sid SemanticID) delete() ! {
	delete_semanticid(sid.id, sid.owner)!
}

pub fn delete_semanticid(id string, owner string) ! {
	db := conf.data.db
	sql db {
		delete from SemanticID where id == id && owner == owner
	}!
}

pub fn resolve_semanticid(id string, owner string) !DBResult[string] {
	res := get_opt[SemanticID](id: id, owner: owner)!
	if sid := res.result {
		return wrap_result([sid.target])
	} else {
		return wrap_result[string]([])
	}
}

pub fn resolve_or_clean_semanticid[T](id string, owner string, assert_id ?string) !DBResult[string] {
	res := resolve_semanticid(id, owner)!
	existing_id := res.result or { return wrap_result[string]([]) }

	if get_opt[T](id: existing_id)!.result == none {
		delete_semanticid(id, owner)!
		return wrap_result[string]([])
	} else {
		if doc_id := assert_id {
			if doc_id != existing_id {
				return error('SemanticID mismatch: expected ${existing_id}, but got ${doc_id}')
			}
		}
		return wrap_result([existing_id])
	}
}
