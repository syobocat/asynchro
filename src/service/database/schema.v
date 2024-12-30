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
	return exists[Schema](schema_url: schema.url)!
}

fn (schema Schema) insert() ! {
	db := conf.data.db
	sql db {
		insert schema into Schema
	}!
	log.info('[DB] Schema recorded: ${schema.url}')
}

fn (schema Schema) update() ! {
	// No need for updating
	return
}

fn get_schema_by_id(id u32) ![]Schema {
	db := conf.data.db
	res := sql db {
		select from Schema where id == id
	}!
	return res
}

fn get_schema_by_url(url string) ![]Schema {
	db := conf.data.db
	res := sql db {
		select from Schema where url == url
	}!
	return res
}

pub fn fetch_schema(url string) !Schema {
	res := get_opt[Schema](schema_url: url)!
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

	inserted := get[Schema](schema_url: url)!

	return inserted
}

pub fn schema_url_to_id(url string) !u32 {
	schema := fetch_schema(url)!
	return schema.id
}

pub fn schema_id_to_url(id u32) !string {
	schema := get[Schema](schema_id: id)!
	return schema.url
}
