module database

import conf
import time

pub struct Timeline implements Insertable {
pub:
	id            string @[primary]
	indexable     bool   @[default: false]
	owner         string
	author        string
	schema_id     u32     @[json: '-']
	schema        string  @[sql: '-']
	policy_id     u32     @[json: '-']
	policy        ?string @[sql: '-']
	policy_params ?string @[json: 'policyParams']
	document      string
	signature     string
	cdate         string
	mdate         string
}

fn (tl Timeline) exists() !bool {
	res := get_by_id[Timeline](tl.id)!
	return !(res.result == none)
}

fn (tl Timeline) insert() ! {
	db := conf.data.db
	sql db {
		insert tl into Timeline
	}!
}

fn (tl Timeline) update() ! {
	db := conf.data.db
	sql db {
		update Timeline set indexable = tl.indexable, author = tl.author, schema_id = tl.schema_id,
		policy_id = tl.policy_id, policy_params = tl.policy_params, document = tl.document,
		signature = tl.signature, mdate = time.utc().format_rfc3339() where id == tl.id
	}!
}
