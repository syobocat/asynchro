module model

import time
import conf

pub type JsonTime = time.Time

pub fn (t JsonTime) str() string {
	return t.format_rfc3339()
}

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
	cdate          JsonTime
	mdate          JsonTime
	last_scraped   JsonTime @[json: 'lastScraped']
}

pub struct Key {
	id string
}
