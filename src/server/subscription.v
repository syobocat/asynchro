module server

import veb
import database

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

@['/api/v1/subscription/:id'; get]
pub fn (app &App) subscription(mut ctx Context, id string) veb.Result {
	res := database.get_opt[database.Subscription](id: id) or {
		return ctx.return_message(.internal_server_error, .error, err.msg())
	}

	subscription := res.result or {
		return ctx.return_message(.not_found, .error, 'subscription not found')
	}

	return ctx.return_content(.ok, .ok, subscription)
}
