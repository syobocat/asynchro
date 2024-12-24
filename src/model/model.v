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

pub struct Commit {
pub:
	document  string
	signature string
	option    string
}

pub struct DBResult[T] {
pub:
	result ?T
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

pub struct Association {
pub:
	id        string @[primary]
	author    string
	owner     string
	schema_id u32    @[json: '-']
	schema    string @[sql: '-']
	target    string
	variant   string
	unique    string
	document  string
	signature string
	cdate     time.Time
	timelines []string
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

pub struct Ack {
pub:
	from      string @[unique: 'relation']
	to        string @[unique: 'relation']
	document  string
	signature string
	valid     bool @[default: false]
}

pub struct Acks {
pub:
	acks []Ack
}

// type Acking = []Ack is problematic because of https://github.com/vlang/v/issues/10763
pub type Acking = Acks
pub type Acker = Acks
