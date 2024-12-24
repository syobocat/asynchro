module db

import conf

pub struct Schema implements Insertable {
pub:
	id  u32 @[primary; serial]
	url string
}

pub fn get_schema_by_id(id u32) !DBResult[Schema] {
	db := conf.data.db
	res := sql db {
		select from Schema where id == id
	}!
	return wrap_result(res)
}

pub fn get_schema_by_url(url string) !DBResult[Schema] {
	db := conf.data.db
	res := sql db {
		select from Schema where url == url
	}!
	return wrap_result(res)
}

fn (schema Schema) exists() !bool {
	res := get_schema_by_url(schema.url)!
	return !(res.result == none)
}

fn (schema Schema) insert() ! {
	db := conf.data.db
	sql db {
		insert schema into Schema
	}!
}

fn (schema Schema) update() ! {
	// No need for updating
	return
}
