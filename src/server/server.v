module server

import term
import log
import veb
import conf

const logo = term.magenta("\n     ,---.                    |\n     |---|,---.,   .,---.,---.|---.,---.,---.\n     |   |`---.|   ||   ||    |   ||    |   |\n     `   '`---'`---|`   '`---'`   '`    `---'\n               `---'\n")
const uwulogo = term.cyan("\n,   .                              |              \n|\\  |,   .,---.,---.,   .,---.,---.|---.,---.,---.\n| \\ ||   |,---|`---.|   ||   ||    |   ||    |   |\n`  `'`---|`---^`---'`---|`   '`---'`   '`    `---'\n     `---'          `---'\n")

pub struct Context {
	veb.Context
}

pub struct App {
	veb.Middleware[Context]
pub:
	data conf.Data
}

pub fn serve(uwu bool) {
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

	if uwu {
		startup_message(uwulogo, app.data.host, app.data.bind, app.data.port)
	} else {
		startup_message(logo, app.data.host, app.data.bind, app.data.port)
	}

	veb.run_at[App, Context](mut app, veb.RunParams{
		family:               .ip
		host:                 app.data.bind
		port:                 app.data.port
		show_startup_message: false
	}) or { panic(err) }
}

fn startup_message(aa string, host string, bind string, port int) {
	println('==================================================')
	println(aa)
	println('This is ${host}. listening on ${bind}:${port}...')
	println('==================================================')
}

fn access_log(ctx &Context) {
	method := ctx.req.method
	url := ctx.req.url
	log.debug('Received request: [${method}] ${url}')
}
