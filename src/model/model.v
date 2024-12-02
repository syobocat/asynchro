module model

pub struct Domain {
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

pub struct Key {
	id string
}
