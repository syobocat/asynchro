module server

import encoding.base64
import log
import veb
import service.store

@['/web/register']
pub fn (app &App) register(mut ctx Context) veb.Result {
	access_log(ctx)
	registration_encoded := ctx.query['registration'] or {
		return ctx.request_error('Please provide a registration query parameter')
	}
	registration := base64.decode_str(registration_encoded.replace_each(['-', '+', '_', '/']))
	signature := ctx.query['signature'] or {
		return ctx.request_error('Please provide a signature')
	}

	match app.data.metadata.registration {
		.open {
			res := store.commit(.execute, registration, signature, none, none) or {
				log.error('Failed to register a new user: ${err}')
				return ctx.server_error('Failed to register a new user.')
			}
			registered_ccid := res.result
			log.info('Account created: ${registered_ccid}')
			callback := ctx.query['callback'] or { return ctx.ok('Account created.') }
			return ctx.redirect(callback, typ: .found)
		}
		.invite {
			return ctx.server_error('Currently Asynchro does not support invitations.')
		}
		.close {
			ctx.res.set_status(.forbidden)
			return ctx.send_response_to_client('text/plain', 'Registration is closed.')
		}
	}
}
