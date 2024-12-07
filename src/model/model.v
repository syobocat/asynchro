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

pub struct MessageResponse {
pub:
	status  Status
	message string
}

pub struct ErrorResponse {
pub:
	error   string
	message ?string
}

pub struct DBResult[T] {
pub:
	result ?T
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
	cdate                 time.Time
	mdate                 time.Time
}

@[table: 'key']
pub struct Key {
pub:
	id               string @[primary]
	root             string
	parent           string
	enact_document   string  @[json: 'enactDocument']
	enact_signature  string  @[json: 'enactSignature']
	revoke_document  ?string @[json: 'revokeDocument']
	revoke_signature ?string @[json: 'revokeSignature']
	valid_since      time.Time
	valid_until      time.Time
}

@[table: 'semantic_id']
pub struct SemanticID {
pub:
	id        string @[unique: 'idowner']
	owner     string @[unique: 'idowner']
	target    string
	document  string
	signature string
	cdate     time.Time
	mdate     time.Time
}

@[table: 'profile']
pub struct Profile {
pub:
	id        string @[primary]
	author    string
	document  string
	signature string
	schema    string
	cdate     time.Time
	mdate     time.Time
}

@[table: 'ack']
pub struct Ack {
pub:
	from      string @[unique: 'relation']
	to        string @[unique: 'relation']
	document  string
	signature string
	valid     bool @[default: false]
}
