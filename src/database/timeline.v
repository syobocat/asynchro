module database

import log
import time
import conf

pub struct Timeline implements MutInsertable {
pub:
	indexable     bool @[default: false]
	owner         string
	author        string
	document      string
	signature     string
	policy_params ?string @[json: 'policyParams']
	cdate         string
	mdate         string
pub mut:
	id        string  @[primary]
	schema_id u32     @[json: '-']
	schema    string  @[sql: '-']
	policy_id u32     @[json: '-']
	policy    ?string @[sql: '-']
}

fn (tl Timeline) exists() !bool {
	return exists[Timeline](id: tl.id)!
}

fn (tl Timeline) insert() ! {
	db := conf.data.db
	sql db {
		insert tl into Timeline
	}!
	log.info('[DB] Timeline created: ${tl.id}')
}

fn (tl Timeline) update() ! {
	db := conf.data.db
	sql db {
		update Timeline set indexable = tl.indexable, author = tl.author, schema_id = tl.schema_id,
		policy_id = tl.policy_id, policy_params = tl.policy_params, document = tl.document,
		signature = tl.signature, mdate = time.utc().format_rfc3339() where id == tl.id
	}!
	log.info('[DB] Timeline updated: ${tl.id}')
}

fn (mut tl Timeline) preprocess() ! {
	tl.id = preprocess_id[Timeline](tl.id)!
	if tl.schema_id == 0 {
		tl.schema_id = schema_url_to_id(tl.schema)!
	}
	if tl.policy_id == 0 {
		if policy := tl.policy {
			tl.policy_id = schema_url_to_id(policy)!
		}
	}
}

fn (mut tl Timeline) postprocess() ! {
	tl.id = postprocess_id[Timeline](tl.id)!
	if tl.schema.len == 0 && tl.schema_id > 0 {
		tl.schema = schema_id_to_url(tl.schema_id)!
	}
	if tl.policy == none && tl.policy_id > 0 {
		tl.policy = schema_id_to_url(tl.policy_id)!
	}
}

fn (tl Timeline) postprocessed() !Timeline {
	mut new := tl
	new.postprocess()!
	return new
}

fn search_timeline(schema string) ![]Timeline {
	db := conf.data.db

	res := sql db {
		select from Timeline where schema == schema
	}!

	return res
}
