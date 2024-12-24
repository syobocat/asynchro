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
	policy        string               @[omitempty; sql: '-']
	policy_params ?string
	cdate         string
	mdate         string
}

fn (pf Profile) exists() !bool {
	res := get_by_id[Profile](pf.id)!
	return !(res.result == none)
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
	id, schema, policy := postprocess(pf, `p`)!
	return Profile{
		...pf
		id:     id
		schema: schema
		policy: policy
	}
}
