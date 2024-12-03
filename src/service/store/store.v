module store

import model
import service.entity

pub enum CommitMode {
	execute
	dry_run
	local_only_execute
}

pub fn commit(mode CommitMode, document model.Document, signature string) ! {
	match document.type {
		.affiliation {
			if document is model.AffiliationDocument {
				entity.affiliation(document, signature)!
			}
		}
		else {
			return error('Not implemented yet')
		}
	}
}
