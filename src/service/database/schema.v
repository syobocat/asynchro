module database

import log
import net.http
import conf

pub struct Schema implements Insertable {
pub:
	id  u32 @[primary; serial]
	url string
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

pub fn fetch_schema(url string) !Schema {
	res := get_schema_by_url(url)!
	if schema := res.result {
		return schema
	}

	_ := http.fetch(http.FetchConfig{
		url:    url
		header: http.new_header_from_map({
			.accept: 'application/json'
		})
	})!

	schema := Schema{
		url: url
	}

	insert(schema)!

	inserted := get_schema_by_url(url)!.result or { return error('Unexpected error') }

	return inserted
}

pub fn schema_url_to_id(url string) !u32 {
	log.debug('[DB] Converting SchemaURL ${url} to ID')
	schema := fetch_schema(url)!
	return schema.id
}

pub fn schema_id_to_url(id u32) !string {
	log.debug('[DB] Converting SchemaID ${id} to URL')
	res := get_schema_by_id(id)!
	schema := res.result or { return error('Not found') }
	return schema.url
}
