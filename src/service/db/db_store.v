module db

pub fn insert(record Insertable) ! {
	return record.insert()
}

pub fn upsert(record Insertable) ! {
	if record.exists()! {
		return record.update()
	} else {
		return record.insert()
	}
}
