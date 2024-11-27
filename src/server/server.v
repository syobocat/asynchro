module server

import veb
import conf

pub struct Context {
	veb.Context
}

pub struct App {
	veb.Middleware[Context]
pub:
	data conf.Data
}

pub fn serve() {
	mut app := &App{
		data: &conf.data
	}
	cors := veb.cors[Context](veb.CorsOptions{
		origins:         ['*']
		allowed_headers: ['*']
		allowed_methods: [.get, .head, .put, .patch, .post, .delete]
		expose_headers:  ['trace-id']
	})
	app.route_use('/api/v1/:endpoint...', cors)

	veb.run_at[App, Context](mut app, veb.RunParams{
		family: .ip
		host:   app.data.bind
		port:   app.data.port
	}) or { panic(err) }
}
