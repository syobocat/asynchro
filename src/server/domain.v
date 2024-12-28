module server

import veb
import service.ccid
import model

@['/api/v1/domain']
pub fn (app &App) my_domain(mut ctx Context) veb.Result {
	domain := model.Domain{
		fqdn:         app.data.host
		ccid:         ccid.privkey_to_ccid(app.data.privkey) or {
			return ctx.server_error('Failed to calculate CCID')
		}
		csid:         ccid.privkey_to_csid(app.data.privkey) or {
			return ctx.server_error('Failed to calculate CSID')
		}
		meta:         app.data.metadata
		dimension:    app.data.dimension
		cdate:        '0001-01-01 00:00:00'
		mdate:        '0001-01-01 00:00:00'
		last_scraped: '0001-01-01 00:00:00'
	}

	return ctx.return_content(.ok, .ok, domain)
}
