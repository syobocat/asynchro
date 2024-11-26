module server

import veb
import conf

struct Context {
	veb.Context
}

pub struct Data {
	conf.Data
}

pub fn serve() {
	mut data := &Data{
		Data: &conf.data
	}
	veb.run_at[Data, Context](mut data, veb.RunParams{
		family: .ip
		host:   data.bind
		port:   data.port
	}) or { panic(err) }
}
