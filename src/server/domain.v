module server

import json
import veb
import conf
import service.ccid

struct Domain {
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

@['/api/v1/domain']
pub fn (data &Data) my_domain(mut ctx Context) veb.Result {
	domain := Domain{
		fqdn:      data.host
		ccid:      ccid.privkey_to_ccid(data.privkey) or {
			return ctx.server_error('Failed to calculate CCID')
		}
		csid:      ccid.privkey_to_csid(data.privkey) or {
			return ctx.server_error('Failed to calculate CSID')
		}
		meta:      data.metadata
		dimension: data.dimension
		cdate: '0001-01-01T00:00:00Z'
		mdate: '0001-01-01T00:00:00Z'
		last_scraped: '0001-01-01T00:00:00Z'
	}

	domain_data := json.encode(domain)

	ctx.set_content_type('application/json')
	return ctx.ok('{"status":"ok","content":${domain_data}}')
}
