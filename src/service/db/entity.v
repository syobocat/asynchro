module db

import time
import conf

pub struct Entity implements Insertable {
pub:
	id                    string @[json: 'ccid'; primary]
	domain                string
	tag                   string
	score                 int     @[default: 0]
	is_score_fixed        bool    @[default: false; json: 'isScoreFixed']
	affiliation_document  string  @[json: 'affiliationDocument']
	affiliation_signature string  @[json: 'affiliationSignature']
	tombstone_document    ?string @[json: 'tombstoneDocument']
	tombstone_signature   ?string @[json: 'tombstoneSignature']
	cdate                 time.Time
	mdate                 time.Time
pub mut:
	alias ?string
}

fn (ent Entity) exists() !bool {
	res := get_by_id[Entity](ent.id)!
	return !(res.result == none)
}

fn (ent Entity) insert() ! {
	db := conf.data.db
	sql db {
		insert ent into Entity
	}!
}

fn (ent Entity) update() ! {
	db := conf.data.db
	sql db {
		update Entity set domain = ent.domain, affiliation_document = ent.affiliation_document,
		affiliation_signature = ent.affiliation_signature, mdate = time.utc() where id == ent.id
	}!
}

pub fn (mut ent Entity) set_alias(alias string) ! {
	set_alias(ent.id, alias)!
	ent.alias = alias
}

pub fn set_alias(id string, alias string) ! {
	db := conf.data.db

	sql db {
		update Entity set alias = alias where id == id
	}!
}
