module server

import veb
import conf
import service.ccid
import model

@['/api/v1/domain'; get]
pub fn (app &App) my_domain(mut ctx Context) veb.Result {
	domain := model.Domain{
		fqdn:         conf.data.host
		ccid:         ccid.privkey_to_ccid(conf.data.privkey) or {
			return ctx.server_error('Failed to calculate CCID')
		}
		csid:         ccid.privkey_to_csid(conf.data.privkey) or {
			return ctx.server_error('Failed to calculate CSID')
		}
		meta:         conf.data.metadata
		dimension:    conf.data.dimension
		cdate:        '0001-01-01 00:00:00'
		mdate:        '0001-01-01 00:00:00'
		last_scraped: '0001-01-01 00:00:00'
	}

	return ctx.return_content(.ok, .ok, domain)
}
