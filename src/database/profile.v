module database

import log
import time
import conf
import model

pub struct Profile implements MutInsertable {
pub:
	author        string
	document      string
	signature     string
	associations  ?[]model.Association @[sql: '-']
	policy_params ?string
	cdate         string
	mdate         string
pub mut:
	id        string  @[primary]
	schema_id u32     @[json: '-']
	schema    string  @[sql: '-']
	policy_id u32     @[json: '-']
	policy    ?string @[sql: '-']
}

fn (pf Profile) exists() !bool {
	return exists[Profile](id: pf.id)!
}

fn (pf Profile) insert() ! {
	db := conf.data.db
	sql db {
		insert pf into Profile
	}!
	log.info('[DB] Profile created: ${pf.id}')
}

fn (pf Profile) update() ! {
	db := conf.data.db
	sql db {
		update Profile set author = pf.author, schema_id = pf.schema_id, policy_id = pf.policy_id,
		policy_params = pf.policy_params, document = pf.document, signature = pf.signature,
		mdate = time.utc().format_rfc3339() where id == pf.id
	}!
	log.info('[DB] Profile updated: ${pf.id}')
}

fn (mut pf Profile) preprocess() ! {
	pf.id = preprocess_id[Profile](pf.id)!
	if pf.schema_id == 0 {
		pf.schema_id = schema_url_to_id(pf.schema)!
	}
	if pf.policy_id == 0 {
		if policy := pf.policy {
			pf.policy_id = schema_url_to_id(policy)!
		}
	}
}

fn (mut pf Profile) postprocess() ! {
	pf.id = postprocess_id[Profile](pf.id)!
	if pf.schema.len == 0 && pf.schema_id > 0 {
		pf.schema = schema_id_to_url(pf.schema_id)!
	}
	if pf.policy == none && pf.policy_id > 0 {
		pf.policy = schema_id_to_url(pf.policy_id)!
	}
}

fn (pf Profile) postprocessed() !Profile {
	mut new := pf
	new.postprocess()!
	return new
}

fn search_profile(author_opt ?string, schema_opt ?string) ![]Profile {
	db := conf.data.db

	author_provided := author_opt != none
	schema_provided := schema_opt != none

	if author_provided && schema_provided {
		author := author_opt or { '' }
		schema := schema_opt or { '' }
		res := sql db {
			select from Profile where author == author && schema == schema
		}!

		return res
	}
	if author_provided {
		author := author_opt or { '' }
		res := sql db {
			select from Profile where author == author
		}!

		return res
	}
	if schema_provided {
		schema := schema_opt or { '' }
		res := sql db {
			select from Profile where schema == schema
		}!

		return res
	}

	return error('Invalid query')
}
