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
	meta           conf.Metadata @[sql: '-']
	is_score_fixed bool          @[json: 'isScoreFixed']
	dimension      string        @[sql: '-']
	cdate          string
	mdate          string
	last_scraped   string @[json: 'lastScraped']
}

pub struct Entity {
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
	alias                 ?string
	cdate                 time.Time
	mdate                 time.Time
}

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

pub struct Profile {
pub:
	id        string @[primary]
	author    string
	document  string
	signature string
	schema    string @[sql: '-']
	cdate     time.Time
	mdate     time.Time
}

pub struct Ack {
pub:
	from      string @[unique: 'relation']
	to        string @[unique: 'relation']
	document  string
	signature string
	valid     bool @[default: false]
}

pub struct Timeline {
pub:
	id            string @[primary]
	indexable     bool   @[default: false]
	owner         string
	author        string
	schema        string  @[sql: '-']
	policy        string  @[sql: '-']
	policy_params ?string @[json: 'policyParams']
	document      string
	signature     string
	cdate         time.Time
	mdate         time.Time
}
