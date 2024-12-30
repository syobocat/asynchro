module database

import time
import conf
import model

pub struct Profile implements Insertable, Normalizable {
pub:
	id            string @[primary]
	author        string
	document      string
	signature     string
	associations  ?[]model.Association @[sql: '-']
	schema_id     u32                  @[json: '-']
	schema        string               @[sql: '-']
	policy_id     u32                  @[json: '-']
	policy        ?string              @[sql: '-']
	policy_params ?string
	cdate         string
	mdate         string
}

fn (pf Profile) exists() !bool {
	return exists[Profile](id: pf.id)!
}

fn (pf Profile) insert() ! {
	db := conf.data.db
	sql db {
		insert pf into Profile
	}!
}

fn (pf Profile) update() ! {
	db := conf.data.db
	sql db {
		update Timeline set author = pf.author, schema_id = pf.schema_id, policy_id = pf.policy_id,
		policy_params = pf.policy_params, document = pf.document, signature = pf.signature,
		mdate = time.utc().format_rfc3339() where id == pf.id
	}!
}

pub fn (pf Profile) preprocess() !Profile {
	id, schema_id, policy_id := preprocess[Profile](pf)!
	return Profile{
		...pf
		id:        id
		schema_id: schema_id
		policy_id: policy_id
	}
}

pub fn (pf Profile) postprocess() !Profile {
	id, schema, policy := postprocess[Profile](pf)!
	return Profile{
		...pf
		id:     id
		schema: schema
		policy: policy
	}
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
