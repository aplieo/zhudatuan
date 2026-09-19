-- First slice: structural extraction from the existing 314-migration PostgreSQL 17 replay.
-- Source: 02_platform_pingtai/database/supabase/migrations/. No L0/L1 records are copied.
-- Structural draft only: original triggers, functions, roles and policies are not yet bundled.
-- Do not clone this as a runnable L database until the original runtime behavior is attached.
begin;
create schema if not exists identity;
create schema if not exists member;
create schema if not exists access;
create schema if not exists organization;

CREATE TABLE access.membership (
    id text NOT NULL,
    member_id text NOT NULL,
    organization_id text NOT NULL,
    client text NOT NULL,
    employee_no text,
    status text NOT NULL,
    access_version bigint DEFAULT 1 NOT NULL,
    joined_at timestamp with time zone,
    left_at timestamp with time zone,
    governance_parent_membership_id text,
    realm_id text,
    account_id text,
    node_profile text DEFAULT 'operating_mall'::text NOT NULL,
    operator_display_name text,
    CONSTRAINT access_membership_profile_client CHECK (((node_profile = 'operating_mall'::text) OR (client = 'storefront'::text))),
    CONSTRAINT membership_access_version_check CHECK ((access_version > 0)),
    CONSTRAINT membership_client_check CHECK ((client = ANY (ARRAY['storefront'::text, 'operator'::text, 'store'::text, 'supplier'::text]))),
    CONSTRAINT membership_realm_account_pair CHECK (((realm_id IS NULL) = (account_id IS NULL))),
    CONSTRAINT membership_status_check CHECK ((status = ANY (ARRAY['invited'::text, 'active'::text, 'suspended'::text, 'left'::text])))
);

CREATE TABLE identity.account (
    id text NOT NULL,
    realm_id text NOT NULL,
    legacy_principal_id text,
    status text NOT NULL,
    credential_version bigint DEFAULT 1 NOT NULL,
    assurance_level smallint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    mobile_ciphertext text,
    mobile_token character(64),
    mobile_masked text,
    phone_verified_at timestamp with time zone,
    CONSTRAINT account_assurance_level_check CHECK (((assurance_level >= 0) AND (assurance_level <= 3))),
    CONSTRAINT account_credential_version_check CHECK ((credential_version > 0)),
    CONSTRAINT account_id_check CHECK ((id ~ '^account:[a-z0-9][A-Za-z0-9:_-]{2,190}$'::text)),
    CONSTRAINT account_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text, 'locked'::text, 'disabled'::text]))),
    CONSTRAINT account_version_check CHECK ((version >= 0)),
    CONSTRAINT identity_account_mobile_pair CHECK (((mobile_ciphertext IS NULL) = (mobile_token IS NULL)))
);

CREATE TABLE identity.principal (
    id text NOT NULL,
    status text NOT NULL,
    credential_version bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT principal_credential_version_check CHECK ((credential_version > 0)),
    CONSTRAINT principal_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text, 'locked'::text, 'disabled'::text]))),
    CONSTRAINT principal_version_check CHECK ((version >= 0))
);

CREATE TABLE identity.realm (
    id text NOT NULL,
    node_id text NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    node_profile text NOT NULL,
    mall_id text,
    host_node_id text,
    host_node_profile text,
    CONSTRAINT identity_realm_node_id_shape CHECK ((node_id ~ '^node:[a-z0-9][a-z0-9-]{0,62}:l[0-9]{1,3}$'::text)),
    CONSTRAINT identity_realm_node_profile_shape CHECK ((((node_profile = 'operating_mall'::text) AND (mall_id IS NOT NULL) AND (((host_node_id IS NULL) AND (host_node_profile IS NULL)) OR ((host_node_id IS NOT NULL) AND (host_node_profile = 'operating_mall'::text) AND (host_node_id <> node_id)))) OR ((node_profile = 'consumer'::text) AND (mall_id IS NULL) AND (host_node_id IS NOT NULL) AND (host_node_profile = 'operating_mall'::text) AND (host_node_id <> node_id)))),
    CONSTRAINT realm_id_check CHECK ((id ~ '^realm:[a-z0-9][a-z0-9-]{0,62}$'::text)),
    CONSTRAINT realm_status_check CHECK ((status = ANY (ARRAY['active'::text, 'disabled'::text]))),
    CONSTRAINT realm_version_check CHECK ((version >= 0))
);

CREATE TABLE member.profile (
    id text NOT NULL,
    principal_id text NOT NULL,
    display_name text NOT NULL,
    mobile_ciphertext text,
    mobile_token character(64),
    email_ciphertext text,
    email_token character(64),
    status text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    mobile_masked text DEFAULT '***'::text NOT NULL,
    CONSTRAINT profile_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text, 'disabled'::text])))
);

CREATE TABLE organization.node (
    id text NOT NULL,
    line_id text NOT NULL,
    sovereignty_tier text NOT NULL,
    node_profile text NOT NULL,
    realm_id text NOT NULL,
    mall_id text,
    status text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT node_check CHECK (((sovereignty_tier <> 'sovereign'::text) OR (node_profile = 'operating_mall'::text))),
    CONSTRAINT node_check1 CHECK (((node_profile <> 'consumer'::text) OR (mall_id IS NULL))),
    CONSTRAINT node_node_profile_check CHECK ((node_profile = ANY (ARRAY['operating_mall'::text, 'consumer'::text]))),
    CONSTRAINT node_sovereignty_tier_check CHECK ((sovereignty_tier = ANY (ARRAY['sovereign'::text, 'hosted'::text]))),
    CONSTRAINT node_status_check CHECK ((status = ANY (ARRAY['provisioning'::text, 'active'::text, 'suspended'::text, 'retired'::text])))
);

CREATE TABLE organization.noderelation (
    line_id text NOT NULL,
    node_id text NOT NULL,
    parent_node_id text,
    original_parent_node_id text,
    signed_level text NOT NULL,
    host_sovereign_node_id text NOT NULL,
    host_sovereignty_tier text DEFAULT 'sovereign'::text NOT NULL,
    relation_version bigint NOT NULL,
    effective_at timestamp with time zone NOT NULL,
    superseded_at timestamp with time zone,
    CONSTRAINT noderelation_check CHECK ((((signed_level = 'L0'::text) AND (parent_node_id IS NULL) AND (original_parent_node_id IS NULL)) OR ((signed_level <> 'L0'::text) AND (parent_node_id IS NOT NULL) AND (original_parent_node_id IS NOT NULL)))),
    CONSTRAINT noderelation_check1 CHECK (((superseded_at IS NULL) OR (superseded_at > effective_at))),
    CONSTRAINT noderelation_host_sovereignty_tier_check CHECK ((host_sovereignty_tier = 'sovereign'::text)),
    CONSTRAINT noderelation_relation_version_check CHECK ((relation_version > 0)),
    CONSTRAINT noderelation_signed_level_check CHECK ((signed_level ~ '^L(-[1-9][0-9]*|[0-9]|10|11)$'::text))
);

ALTER TABLE ONLY access.membership
    ADD CONSTRAINT membership_id_account_realm_unique UNIQUE (id, account_id, realm_id);

ALTER TABLE ONLY access.membership
    ADD CONSTRAINT membership_pkey PRIMARY KEY (id);

ALTER TABLE ONLY identity.account
    ADD CONSTRAINT account_id_realm_id_key UNIQUE (id, realm_id);

ALTER TABLE ONLY identity.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);

ALTER TABLE ONLY identity.realm
    ADD CONSTRAINT identity_realm_id_node_profile_unique UNIQUE (id, node_profile);

ALTER TABLE ONLY identity.realm
    ADD CONSTRAINT identity_realm_node_id_profile_unique UNIQUE (node_id, node_profile);

ALTER TABLE ONLY identity.principal
    ADD CONSTRAINT principal_pkey PRIMARY KEY (id);

ALTER TABLE ONLY identity.realm
    ADD CONSTRAINT realm_node_id_key UNIQUE (node_id);

ALTER TABLE ONLY identity.realm
    ADD CONSTRAINT realm_pkey PRIMARY KEY (id);

ALTER TABLE ONLY member.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (id);

ALTER TABLE ONLY member.profile
    ADD CONSTRAINT profile_principal_id_key UNIQUE (principal_id);

ALTER TABLE ONLY organization.node
    ADD CONSTRAINT node_id_line_id_key UNIQUE (id, line_id);

ALTER TABLE ONLY organization.node
    ADD CONSTRAINT node_id_line_id_sovereignty_tier_key UNIQUE (id, line_id, sovereignty_tier);

ALTER TABLE ONLY organization.node
    ADD CONSTRAINT node_pkey PRIMARY KEY (id);

ALTER TABLE ONLY organization.node
    ADD CONSTRAINT node_realm_id_key UNIQUE (realm_id);

ALTER TABLE ONLY organization.noderelation
    ADD CONSTRAINT noderelation_pkey PRIMARY KEY (line_id, node_id, relation_version);

CREATE INDEX access_membership_governance_parent_idx ON access.membership USING btree (governance_parent_membership_id) WHERE (governance_parent_membership_id IS NOT NULL);

CREATE INDEX access_membership_realm_account_idx ON access.membership USING btree (realm_id, account_id, status);

CREATE INDEX member_scope_status ON access.membership USING btree (organization_id, status, id);

CREATE UNIQUE INDEX membership_current_operator_subject_unique ON access.membership USING btree (member_id, organization_id, client) WHERE ((client = 'operator'::text) AND (status <> 'left'::text));

CREATE UNIQUE INDEX membership_nonoperator_subject_unique ON access.membership USING btree (member_id, organization_id, client) WHERE (client <> 'operator'::text);

CREATE UNIQUE INDEX identity_account_realm_legacy_principal_unique ON identity.account USING btree (realm_id, legacy_principal_id) WHERE (legacy_principal_id IS NOT NULL);

CREATE UNIQUE INDEX identity_account_realm_mobile_unique ON identity.account USING btree (realm_id, mobile_token) WHERE (mobile_token IS NOT NULL);

CREATE INDEX organization_noderelation_host_lookup ON organization.noderelation USING btree (line_id, host_sovereign_node_id, effective_at, superseded_at);

CREATE UNIQUE INDEX organization_noderelation_one_current_parent ON organization.noderelation USING btree (line_id, node_id) WHERE (superseded_at IS NULL);

CREATE INDEX organization_noderelation_parent_lookup ON organization.noderelation USING btree (line_id, parent_node_id, effective_at, superseded_at);

ALTER TABLE ONLY access.membership
    ADD CONSTRAINT access_membership_realm_profile FOREIGN KEY (realm_id, node_profile) REFERENCES identity.realm(id, node_profile) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY access.membership
    ADD CONSTRAINT membership_governance_parent_membership_id_fkey FOREIGN KEY (governance_parent_membership_id) REFERENCES access.membership(id) ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE ONLY access.membership
    ADD CONSTRAINT membership_member_id_fkey FOREIGN KEY (member_id) REFERENCES member.profile(id);

ALTER TABLE ONLY access.membership
    ADD CONSTRAINT membership_realm_account FOREIGN KEY (account_id, realm_id) REFERENCES identity.account(id, realm_id);

ALTER TABLE ONLY identity.account
    ADD CONSTRAINT account_legacy_principal_id_fkey FOREIGN KEY (legacy_principal_id) REFERENCES identity.principal(id);

ALTER TABLE ONLY identity.account
    ADD CONSTRAINT account_realm_id_fkey FOREIGN KEY (realm_id) REFERENCES identity.realm(id);

ALTER TABLE ONLY identity.realm
    ADD CONSTRAINT identity_realm_consumer_host FOREIGN KEY (host_node_id, host_node_profile) REFERENCES identity.realm(node_id, node_profile);

ALTER TABLE ONLY organization.node
    ADD CONSTRAINT node_realm_id_fkey FOREIGN KEY (realm_id) REFERENCES identity.realm(id);

ALTER TABLE ONLY organization.noderelation
    ADD CONSTRAINT noderelation_host_node_fkey FOREIGN KEY (host_sovereign_node_id) REFERENCES organization.node(id);

ALTER TABLE ONLY organization.noderelation
    ADD CONSTRAINT noderelation_node_id_line_id_fkey FOREIGN KEY (node_id, line_id) REFERENCES organization.node(id, line_id);

ALTER TABLE ONLY organization.noderelation
    ADD CONSTRAINT noderelation_original_parent_node_id_line_id_fkey FOREIGN KEY (original_parent_node_id, line_id) REFERENCES organization.node(id, line_id);

ALTER TABLE ONLY organization.noderelation
    ADD CONSTRAINT noderelation_parent_node_id_line_id_fkey FOREIGN KEY (parent_node_id, line_id) REFERENCES organization.node(id, line_id);

commit;

