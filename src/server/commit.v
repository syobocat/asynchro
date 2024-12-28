module server

import json
import log
import veb
import model
import service.store

@['/api/v1/commit'; post]
pub fn (app &App) commit(mut ctx Context) veb.Result {
	data := ctx.req.data
	request := json.decode(model.Commit, data) or {
		return ctx.return_error(.bad_request, err.msg(), none)
	}

	if request.document.len > 8192 {
		return ctx.return_error(.bad_request, 'Document size is too large', none)
	}

	// TODO: Get key

	res := store.commit(.execute, request.document, request.signature, request.option,
		none) or { // TODO: replace `none` with the key
		log.error('Commit failed: ${err}')
		return ctx.return_error(.internal_server_error, err.msg(), none)
	}

	match res.status {
		.ok {
			return ctx.return_content(.ok, .ok, res.result)
		}
		.already_exists, .already_deleted {
			return ctx.return_content(.ok, .processed, res.result)
		}
		.permission_denied {
			return ctx.return_content(.forbidden, .error, res.result)
		}
	}
}
