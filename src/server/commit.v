module server

import veb

@['/api/v1/commit'; post]
pub fn (app &App) commit(mut ctx Context) veb.Result {
	access_log(ctx)
	return ctx.ok('')
}
