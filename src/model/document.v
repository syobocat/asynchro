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

pub struct Document {
pub:
	signer          string
	type            DocumentType
	signed_at       string @[json: 'signedAt']
	id              ?string
	semantic_id     ?string @[json: 'semanticID']
	owner           ?string
	schema          ?string
	policy          ?string
	policy_params   ?string @[json: 'policyParams']
	policy_defaults ?string @[json: 'policyDefaults']
	key_id          ?string

	body ?string
}

pub struct AffiliationDocument {
	Document
pub:
	domain string
}

pub struct TombstoneDocument {
	Document
pub:
	reason string
}

pub struct RelationDocument {
	Document
pub:
	from string
	to   string
}

pub type AckDocument = RelationDocument
pub type UnackDocument = RelationDocument

pub struct MessageDocument {
	Document
pub:
	timelines []string
}

pub struct AssociationDocument {
	Document
pub:
	timelines []string
	variant   string
	target    string
}

pub type ProfileDocument = Document

pub struct TimelineDocument {
	Document
pub:
	indexable    bool
	domain_owned bool @[json: 'domainOwned']
}

pub type SubscriptionDocument = TimelineDocument

pub struct PassportDocument {
	Document
pub:
	domain string
	entity string
	keys   []Key
}

pub struct TargettedDocument {
	Document
pub:
	target string
}

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

pub type DeleteDocument = TargettedDocument
pub type RevokeDocument = TargettedDocument
