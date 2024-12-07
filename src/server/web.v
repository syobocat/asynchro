module server

import encoding.base64
import json
import log
import veb
import model
import service.store

@['/web/register']
pub fn (app &App) register(mut ctx Context) veb.Result {
	registration_encoded := ctx.query['registration'] or {
		return ctx.request_error('Please provide a registration query parameter')
	}
	registration_json := base64.decode_str(registration_encoded.replace_each(['-', '+', '_', '/']))
	registration := json.decode(model.AffiliationDocument, registration_json) or {
		return ctx.request_error('Invalid json')
	}
	signature := ctx.query['signature'] or {
		return ctx.request_error('Please provide a signature')
	}

	match app.data.metadata.registration {
		.open {
			registered_ccid := store.commit(.execute, registration, registration_json,
				signature) or {
				log.error('Failed to register a new user: ${err}')
				return ctx.server_error('Failed to register a new user.')
			}
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
