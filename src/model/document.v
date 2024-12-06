module model

pub enum DocumentType {
	ack
	unack
	affiliation
	association
	delete
	enact
	revoke
	event
	message
	passport
	profile
	subscribe
	unsubscribe
	subscription
	timeline
	retract
	tombstone
}

pub type Document = DocumentBase
	| AffiliationDocument
	| TombstoneDocument
	| AckDocument
	| UnackDocument
	| MessageDocument
	| AssociationDocument
	| ProfileDocument
	| TimelineDocument
	| SubscriptionDocument
	| PassportDocument
	| DeleteDocument
	| RevokeDocument
	| RetractDocument
	| SubscribeDocument
	| UnsubscribeDocument

pub struct DocumentBase {
pub:
	signer          string
	key_id          string @[omitempty]
	type            DocumentType
	signed_at       string @[json: 'signedAt']
	id              ?string
	semantic_id     ?string @[json: 'semanticID']
	owner           ?string
	schema          ?string
	policy          ?string
	policy_params   ?string @[json: 'policyParams']
	policy_defaults ?string @[json: 'policyDefaults']

	body ?string
}

pub struct AffiliationDocument {
	DocumentBase
pub:
	domain string
}

pub struct TombstoneDocument {
	DocumentBase
pub:
	reason string
}

pub struct RelationDocument {
	DocumentBase
pub:
	from string
	to   string
}

pub type AckDocument = RelationDocument
pub type UnackDocument = RelationDocument

pub struct MessageDocument {
	DocumentBase
pub:
	timelines []string
}

pub struct AssociationDocument {
	DocumentBase
pub:
	timelines []string
	variant   string
	target    string
}

pub type ProfileDocument = DocumentBase

pub struct TimelineDocument {
	DocumentBase
pub:
	indexable    bool
	domain_owned bool @[json: 'domainOwned']
}

pub type SubscriptionDocument = TimelineDocument

pub struct PassportDocument {
	DocumentBase
pub:
	domain string
	entity string
	keys   []Key
}

pub struct TargettedDocument {
	DocumentBase
pub:
	target string
}

pub type DeleteDocument = TargettedDocument
pub type RevokeDocument = TargettedDocument

pub struct RetractDocument {
	TargettedDocument
pub:
	timeline string
}

pub struct SubscribeDocument {
	TargettedDocument
pub:
	subscription string
}

pub type UnsubscribeDocument = SubscribeDocument
