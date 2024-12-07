module server

import veb

@['/services']
pub fn (app &App) services(mut ctx Context) veb.Result {
	access_log(ctx)
	return ctx.send_response_to_client('application/json', '{"net.concrnt.api":{"path":"/api/v1"},"net.concrnt.webui":{"path":"/web"}')
}
