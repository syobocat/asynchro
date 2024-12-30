module server

import veb
import service.database

@['/api/v1/subscriptions/mine'; get]
pub fn (app &App) subscriptions(mut ctx Context) veb.Result {
	requester := ctx.requester_id or {
		return ctx.return_message(.forbidden, .error, 'requester not found')
	}

	subscriptions := database.search[database.Subscription](author: requester) or {
		return ctx.return_message(.internal_server_error, .error, err.msg())
	}

	return ctx.return_content(.ok, .ok, subscriptions)
}
