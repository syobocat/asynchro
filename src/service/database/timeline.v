module database

import conf
import time

pub struct Timeline implements Insertable, Normalizable {
pub:
	id            string @[primary]
	indexable     bool   @[default: false]
	owner         string
	author        string
	document      string
	signature     string
	schema_id     u32     @[json: '-']
	schema        string  @[sql: '-']
	policy_id     u32     @[json: '-']
	policy        string  @[omitempty; sql: '-']
	policy_params ?string @[json: 'policyParams']
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

pub fn (tl Timeline) preprocess() !Timeline {
	id, schema_id, policy_id := preprocess[Timeline](tl)!
	return Timeline{
		...tl
		id:        id
		schema_id: schema_id
		policy_id: policy_id
	}
}

pub fn (tl Timeline) postprocess() !Timeline {
	id, schema, policy := postprocess(tl, `t`)!
	return Timeline{
		...tl
		id:     id
		schema: schema
		policy: policy
	}
}
