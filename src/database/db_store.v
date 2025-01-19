module database

pub fn insert(record ImutInsertable) ! {
	return record.insert()
}

pub fn upsert(record ImutInsertable) ! {
	if record.exists()! {
		return record.update()
	} else {
		return record.insert()
	}
}

pub fn insert_mut(mut record MutInsertable) ! {
	record.preprocess()!
	record.insert()!
	record.postprocess()!
}

pub fn upsert_mut(mut record MutInsertable) ! {
	record.preprocess()!
	if record.exists()! {
		record.update()!
	} else {
		record.insert()!
	}
	record.postprocess()!
}
