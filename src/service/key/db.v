module key

import conf
import model

// V does not support Result of Option
pub fn get(key_id string) ![]model.Key {
	db := conf.data.db

	key := sql db {
		select from model.Key where id == key_id
	}!

	return key
}
