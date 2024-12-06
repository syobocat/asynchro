module server

import term
import veb
import conf

const logo = term.magenta("\n     ,---.                    |\n     |---|,---.,   .,---.,---.|---.,---.,---.\n     |   |`---.|   ||   ||    |   ||    |   |\n     `   '`---'`---|`   '`---'`   '`    `---'\n               `---'\n")

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

	startup_message(app.data.host, app.data.bind, app.data.port)
	veb.run_at[App, Context](mut app, veb.RunParams{
		family:               .ip
		host:                 app.data.bind
		port:                 app.data.port
		show_startup_message: false
	}) or { panic(err) }
}

fn startup_message(host string, bind string, port int) {
	println('==================================================')
	println(logo)
	println('This is ${host}. listening on ${bind}:${port}...')
	println('==================================================')
}
