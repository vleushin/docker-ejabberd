###
###               ejabberd configuration file
###
###

### The parameters used in this configuration file are explained in more detail
### in the ejabberd Installation and Operation Guide.
### Please consult the Guide in case of doubts, it is included with
### your copy of ejabberd, and is also available online at
### http://www.process-one.net/en/ejabberd/docs/

###   =======
###   LOGGING

loglevel: {{ env['LOGLEVEL'] or 4 }}
log_rotate_size: 10485760
log_rotate_count: 0
log_rate_limit: 100

## watchdog_admins:
##   - "bob@example.com"

###   ================
###   SERVED HOSTNAMES

hosts:
{%- for xmpp_domain in env['XMPP_DOMAIN'].split() %}
  - "{{ xmpp_domain }}"
{%- endfor %}

##
## route_subdomains: Delegate subdomains to other XMPP servers.
## For example, if this ejabberd serves example.org and you want
## to allow communication with an XMPP server called im.example.org.
##
## route_subdomains: s2s

###   ===============
###   LISTENING PORTS

listen:
  -
    port: 5222
    module: ejabberd_c2s
    starttls: true
    max_stanza_size: 65536
    shaper: c2s_shaper
    access: c2s
  -
    port: 5269
    module: ejabberd_s2s_in
  -
    port: 4560
    module: ejabberd_xmlrpc
  -
    port: 5280
    module: ejabberd_http
    ## request_handlers:
    ##   "/pub/archive": mod_http_fileserver
    web_admin: true
    http_poll: true
    http_bind: true
    ## register: true
    captcha: true
    tls: true
    certfile: "/opt/ejabberd/ssl/host.pem"

###   SERVER TO SERVER
###   ================

s2s_use_starttls: optional
s2s_certfile: "/opt/ejabberd/ssl/host.pem"
## s2s_protocol_options:
##   - "no_sslv3"
##   - "no_tlsv1"

###   ==============
###   AUTHENTICATION

auth_method:
  - odbc
{%- if env['AUTH_METHOD'] == "anonymous" %}
  - anonymous

Anonymous login support:
  anonymous_protocol: login_anon
  allow_multiple_connections: true
{% endif %}


odbc_type: mysql
odbc_server: "mysql"
odbc_database: "ejabberd"
odbc_username: "ejabberd"
odbc_password: "ejabberd"
odbc_pool_size: 10

###   ===============
###   TRAFFIC SHAPERS

shaper:
  normal: 1000
  fast: 50000
max_fsm_queue: 1000

###   ====================
###   ACCESS CONTROL LISTS

acl:
  admin:
    user:
    {%- if env['EJABBERD_ADMIN'] %}
      {%- for admin in env['EJABBERD_ADMIN'].split() %}
      - "{{ admin.split('@')[0] }}": "{{ admin.split('@')[1] }}"
      {%- endfor %}
    {%- else %}
      - "admin": "{{ env['XMPP_DOMAIN'].split()[0] }}"
    {%- endif %}
  local:
    user_regexp: ""

###   ============
###   ACCESS RULES

access:
  max_user_sessions:
    all: 10
  max_user_offline_messages:
    admin: 5000
    all: 100
  local:
    local: allow
  c2s:
    blocked: deny
    all: allow
  c2s_shaper:
    admin: none
    all: normal
  s2s_shaper:
    all: fast
  announce:
    admin: allow
  configure:
    admin: allow
  muc_admin:
    admin: allow
  muc_create:
    local: allow
  muc:
    all: allow
  pubsub_createnode:
    local: allow
  register:
    all: allow
  trusted_network:
    loopback: allow


language: "en"

###   =======
###   MODULES

modules:
  mod_adhoc: {}
  mod_announce: # recommends mod_adhoc
    access: announce
  mod_blocking: {} # requires mod_privacy
  mod_caps: {}
  mod_carboncopy: {}
  mod_client_state:
    drop_chat_states: true
    queue_presence: false
  mod_configure: {} # requires mod_adhoc
  mod_disco: {}
  ## mod_echo: {}
  mod_irc: {}
  mod_http_bind: {}
  ## mod_http_fileserver:
  ##   docroot: "/var/www"
  ##   accesslog: "/var/log/ejabberd/access.log"
  mod_last: {}
  mod_muc:
    host: "conference.@HOST@"
    access: muc
    access_create: muc_create
    access_persistent: muc_create
    access_admin: muc_admin
  ## mod_muc_log: {}
  mod_offline:
    db_type: odbc
    access_max_user_messages: max_user_offline_messages
  mod_ping: {}
  ## mod_pres_counter:
  ##   count: 5
  ##   interval: 60
  mod_privacy: {}
  mod_private: {}
  ## mod_proxy65: {}
  mod_pubsub:
    access_createnode: pubsub_createnode
    ## reduces resource comsumption, but XEP incompliant
    ignore_pep_from_offline: true
    ## XEP compliant, but increases resource comsumption
    ## ignore_pep_from_offline: false
    last_item_cache: false
    plugins:
      - "flat"
      - "hometree"
      - "pep" # pep requires mod_caps
  mod_register:
    ## captcha_protected: true
    ## password_strength: 32
    welcome_message:
      subject: "Welcome!"
      body: |-
        Hi.
        Welcome to this XMPP server.
    access: register
  mod_roster: {}
  mod_shared_roster: {}
  mod_stats: {}
  mod_time: {}
  mod_vcard: {}
  mod_version: {}

###   ============
###   HOST CONFIG

host_config:
{%- for xmpp_domain in env['XMPP_DOMAIN'].split() %}
  "{{ xmpp_domain }}":
    domain_certfile: "/opt/ejabberd/ssl/{{ xmpp_domain }}.pem"
{%- endfor %}

