module model

import time
import conf

pub enum Status {
	ok
	processed
	error
}

pub struct Response[T] {
pub:
	status  Status
	content T
}

pub struct Domain {
pub:
	fqdn           string
	ccid           string
	csid           string
	tag            string
	score          int
	meta           conf.Metadata
	is_score_fixed bool @[json: 'isScoreFixed']
	dimension      string
	cdate          string
	mdate          string
	last_scraped   string @[json: 'lastScraped']
}

@[table: 'entity']
pub struct Entity {
pub:
	ccid                  string @[primary]
	domain                string
	tag                   string
	score                 int     @[default: 0]
	is_score_fixed        bool    @[default: false; json: 'isScoreFixed']
	affiliation_document  string  @[json: 'affiliationDocument']
	affiliation_signature string  @[json: 'affiliationSignature']
	tombstone_document    ?string @[json: 'tombstoneDocument']
	tombstone_signature   ?string @[json: 'tombstoneSignature']
	alias                 ?string
	cdate                 time.Time @[default: 'CURRENT_TIME']
	mdate                 time.Time @[default: 'CURRENT_TIME']
}

pub struct Key {
	id string
}
