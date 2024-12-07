module key

import conf
import model

pub fn get(key_id string) !model.DBResult[model.Key] {
	db := conf.data.db

	keys := sql db {
		select from model.Key where id == key_id
	}!

	return model.DBResult[model.Key]{
		result: if key := keys[0] { key } else { none }
	}
}
