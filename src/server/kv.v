module server

import veb
import service.database

@['/api/v1/kv/:key'; get]
pub fn (app &App) get_kv(mut ctx Context, key string) veb.Result {
	requester := ctx.requester_id or {
		return ctx.return_message(.forbidden, .error, 'requester not found')
	}

	res := database.get_opt[database.KV](id: key, owner: requester) or {
		return ctx.return_message(.internal_server_error, .error, err.msg())
	}
	kv := res.result or { return ctx.return_message(.not_found, .error, 'userkv not found') }

	return ctx.return_content(.ok, .ok, kv)
}

@['/api/v1/kv/:key'; put]
pub fn (app &App) put_kv(mut ctx Context, key string) veb.Result {
	requester := ctx.requester_id or {
		return ctx.return_message(.forbidden, .error, 'requester not found')
	}

	value := ctx.req.data

	kv := database.KV{
		key:   key
		owner: requester
		value: value
	}

	database.insert(kv) or { return ctx.return_message(.internal_server_error, .error, err.msg()) }

	return ctx.return(.ok, .ok)
}
