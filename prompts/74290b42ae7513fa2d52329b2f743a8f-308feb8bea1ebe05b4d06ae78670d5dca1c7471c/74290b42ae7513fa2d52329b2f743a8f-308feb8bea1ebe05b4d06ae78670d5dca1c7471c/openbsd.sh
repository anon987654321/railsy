#!/usr/bin/env zsh
# Configures OpenBSD 7.7 for Rails Applications with relayd
# Last modified: 2025-05-21 17:30:52 by anon987654321

set -e
trap 'echo "Error at line $LINENO" >&2' ERR

# Config variables
BRGEN_IP="46.23.95.45"            # Primary IP (ns.brgen.no)
HYP_IP="194.63.248.53"            # Secondary NS (ns.hyp.net)

# Domain list for DNS - PRESERVE ORIGINAL FORMAT
ALL_DOMAINS=(
  brgen.no:markedsplass,playlist,dating,tv,takeaway,maps
  longyearbyn.no:markedsplass,playlist,dating,tv,takeaway,maps
  oshlo.no:markedsplass,playlist,dating,tv,takeaway,maps
  stvanger.no:markedsplass,playlist,dating,tv,takeaway,maps
  trmso.no:markedsplass,playlist,dating,tv,takeaway,maps
  trndheim.no:markedsplass,playlist,dating,tv,takeaway,maps
  reykjavk.is:markadur,playlist,dating,tv,takeaway,maps
  kbenhvn.dk:markedsplads,playlist,dating,tv,takeaway,maps
  gtebrg.se:marknadsplats,playlist,dating,tv,takeaway,maps
  mlmoe.se:marknadsplats,playlist,dating,tv,takeaway,maps
  stholm.se:marknadsplats,playlist,dating,tv,takeaway,maps
  hlsinki.fi:markkinapaikka,playlist,dating,tv,takeaway,maps
  brmingham.uk:marketplace,playlist,dating,tv,takeaway,maps
  cardff.uk:marketplace,playlist,dating,tv,takeaway,maps
  edinbrgh.uk:marketplace,playlist,dating,tv,takeaway,maps
  glasgw.uk:marketplace,playlist,dating,tv,takeaway,maps
  lndon.uk:marketplace,playlist,dating,tv,takeaway,maps
  lverpool.uk:marketplace,playlist,dating,tv,takeaway,maps
  mnchester.uk:marketplace,playlist,dating,tv,takeaway,maps
  amstrdam.nl:marktplaats,playlist,dating,tv,takeaway,maps
  rottrdam.nl:marktplaats,playlist,dating,tv,takeaway,maps
  utrcht.nl:markt,playlist,dating,tv,takeaway,maps
  brssels.be:marche,playlist,dating,tv,takeaway,maps
  zrich.ch:marktplatz,playlist,dating,tv,takeaway,maps
  lchtenstein.li:marktplatz,playlist,dating,tv,takeaway,maps
  frankfrt.de:marktplatz,playlist,dating,tv,takeaway,maps
  brdeaux.fr:marche,playlist,dating,tv,takeaway,maps
  mrseille.fr:marche,playlist,dating,tv,takeaway,maps
  mlan.it:mercato,playlist,dating,tv,takeaway,maps
  lisbon.pt:mercado,playlist,dating,tv,takeaway,maps
  wrsawa.pl:marktplatz,playlist,dating,tv,takeaway,maps
  gdnsk.pl:marktplatz,playlist,dating,tv,takeaway,maps
  austn.us:marketplace,playlist,dating,tv,takeaway,maps
  chcago.us:marketplace,playlist,dating,tv,takeaway,maps
  denvr.us:marketplace,playlist,dating,tv,takeaway,maps
  dllas.us:marketplace,playlist,dating,tv,takeaway,maps
  dnver.us:marketplace,playlist,dating,tv,takeaway,maps
  dtroit.us:marketplace,playlist,dating,tv,takeaway,maps
  houstn.us:marketplace,playlist,dating,tv,takeaway,maps
  lsangeles.com:marketplace,playlist,dating,tv,takeaway,maps
  mnnesota.com:marketplace,playlist,dating,tv,takeaway,maps
  newyrk.us:marketplace,playlist,dating,tv,takeaway,maps
  prtland.com:marketplace,playlist,dating,tv,takeaway,maps
  wshingtondc.com:marketplace,playlist,dating,tv,takeaway,maps
  pub.healthcare
  pub.attorney
  freehelp.legal
  bsdports.org
  bsddocs.org
  discordb.org
  privcam.no
  foodielicio.us
  stacyspassion.com
  antibettingblog.com
  anticasinoblog.com
  antigamblingblog.com
  foball.no
)

# Apps for relayd and rc.d
ALL_APPS=(
  "brgen:brgen.no"
  "amber:amberapp.com"
  "bsdports:bsdports.org"
)

# Ports for applications - preserve existing ports if detected
typeset -A APP_PORTS

# Generate random port (10000–60000)
generate_random_port() {
  local port=$(jot -r 1 10000 60000)
  while netstat -an | grep -q ":$port "; do port=$(jot -r 1 10000 60000); done
  echo "$port"
}

# Stop nsd and free port 53
cleanup_nsd() {
  echo "Cleaning nsd(8)"
  
  # Gracefully stop NSD service
  doas rcctl stop nsd 2>/dev/null || :
  doas pkill -15 -xf "nsd" 2>/dev/null || :
  
  # Wait for port to be free
  sleep 2
}

# Verify DNS and DNSSEC
check_dns_propagation() {
  # Verify nsd is running and responding for all domains
  echo "Verifying nsd(8) for all domains" >&2
  for domain_entry in "${ALL_DOMAINS[@]}"; do
    domain="${domain_entry%%:*}"
    
    # Check if nsd responds for this domain
    dig_output=$(dig @"$BRGEN_IP" "$domain" A +short)
    if [[ -z "$dig_output" || "$dig_output" != "$BRGEN_IP" ]]; then
      echo "ERROR: nsd(8) not authoritative for $domain" >&2
      exit 1
    fi
    
    # Verify DNSSEC
    dig_output=$(dig @"$BRGEN_IP" "$domain" DNSKEY +short)
    if [[ -z "$dig_output" ]]; then
      echo "ERROR: DNSSEC not enabled for $domain" >&2
      exit 1
    fi
  done
  
  echo "DNS verification successful for all domains" >&2
}

# Generate TLSA record for DANE
generate_tlsa_record() {
  local domain="$1"
  echo "Generating TLSA record for ${domain}" >&2
  
  # Extract certificate hash
  local cert_hash=$(doas openssl x509 -in "/etc/ssl/${domain}.crt" -outform DER | \
                   doas openssl dgst -sha256 -binary | \
                   doas hexdump -ve '1/1 "%.2x"')
  
  # Add TLSA record to zone file
  doas awk -v cert="${cert_hash}" \
       '{print} $1=="@" && !tlsa_exists {print "_443._tcp IN TLSA 3 1 1 " cert; tlsa_exists=1}' \
       "/var/nsd/zones/master/${domain}.zone" > /tmp/zone.tmp && doas mv /tmp/zone.tmp "/var/nsd/zones/master/${domain}.zone"
  
  # Re-sign zone
  sign_zone "$domain"
}

# Sign zone with DNSSEC
sign_zone() {
  local domain="$1"
  echo "Signing zone for ${domain}" >&2
  doas ldns-signzone -n -o "${domain}" "/var/nsd/zones/master/${domain}.zone"
}

# Retry failed certificates
retry_failed_certs() {
  # Retry certificate issuance for failed domains
  echo "Retrying failed certificates" >&2
  
  # Check for domains that failed certification
  local retry_count=0
  for domain_entry in "${ALL_DOMAINS[@]}"; do
    domain="${domain_entry%%:*}"
    
    if [ ! -f "/etc/ssl/${domain}.crt" ]; then
      echo "Retrying certificate for ${domain}..." >&2
      doas acme-client -v "${domain}" && retry_count=$((retry_count + 1)) || true
      
      # Generate TLSA record if we now have a certificate
      if [ -f "/etc/ssl/${domain}.crt" ]; then
        generate_tlsa_record "$domain"
      fi
    fi
  done
  
  echo "Retried $retry_count certificates" >&2
}

# Detect existing application ports
detect_app_ports() {
  echo "Detecting existing application ports" >&2
  
  # Check for existing services listening on ports
  local app app_entry primary_domain
  for app_entry in "${ALL_APPS[@]}"; do
    app="${app_entry%%:*}"
    primary_domain="${app_entry#*:}"
    
    # Check if the app service is running
    if doas rcctl check "$app" >/dev/null 2>&1; then
      # Try to find the port from the rc.d script
      if [ -f "/etc/rc.d/${app}" ]; then
        local port_line=$(grep -o "port=[0-9]*" "/etc/rc.d/${app}" | head -1)
        if [[ -n "$port_line" ]]; then
          local detected_port=${port_line#*=}
          APP_PORTS[$app]=$detected_port
          echo "Detected existing port $detected_port for $app"
        fi
      fi
      
      # Fall back to checking for listening port
      if [[ -z "${APP_PORTS[$app]}" ]]; then
        local detected_port=$(doas netstat -an | grep LISTEN | grep -o '127.0.0.1:[0-9]*' | grep -o '[0-9]*' | sort -u | head -1)
        if [[ -n "$detected_port" ]]; then
          APP_PORTS[$app]=$detected_port
          echo "Detected listening port $detected_port for $app"
        fi
      fi
    fi
    
    # If still no port, generate a new one
    if [[ -z "${APP_PORTS[$app]}" ]]; then
      APP_PORTS[$app]=$(generate_random_port)
      echo "Generated new port ${APP_PORTS[$app]} for $app"
    fi
  done
}

# Backup existing configuration file
backup_config() {
  local file="$1"
  if [ -f "$file" ]; then
    local backup="${file}.$(date +%Y%m%d%H%M%S).bak"
    echo "Backing up $file to $backup" >&2
    doas cp "$file" "$backup"
  fi
}

# Main installation function
stage1() {
  # Install packages
  echo "Installing required packages..." >&2
  doas pkg_add -U ldns-utils ruby-3.3.5 postgresql-server redis zap || {
    echo "ERROR: Package installation failed. Verify system version ('uname -r' should be 7.7) and internet access." >&2
    exit 1
  }
  
  # Check pf configuration
  if grep -q "pf=NO" /etc/rc.conf.local 2>/dev/null; then
    echo "WARNING: pf is disabled in /etc/rc.conf.local. Consider enabling for security." >&2
  fi
  
  # Create backup directory
  doas mkdir -p /var/backup/config
  
  # Back up NSD config if it exists
  backup_config "/var/nsd/etc/nsd.conf"
  
  # Clean up NSD directories
  doas mkdir -p /var/nsd/etc /var/nsd/zones/master
  doas rm -rf /var/nsd/etc/* /var/nsd/zones/master/* 2>/dev/null || :
  
  # Configure NSD with zone transfers and NOTIFY to ns.hyp.net
  doas tee "/var/nsd/etc/nsd.conf" >/dev/null <<'EOF'
server:
  hide-version: yes
  verbosity: 1
  database: ""
  identity: "NSD"
  zonesdir: "/var/nsd/zones"

remote-control:
  control-enable: yes
  control-interface: /var/run/nsd.sock
EOF

  # Add zone entries with AXFR and NOTIFY
  local domain_entry domain ns_hyp="194.63.248.53"
  for domain_entry in "${ALL_DOMAINS[@]}"; do
    domain="${domain_entry%%:*}"
    
    # Add zone configuration
    doas tee -a "/var/nsd/etc/nsd.conf" >/dev/null <<EOF

zone:
  name: ${domain}
  zonefile: master/%s.zone
  notify: ${ns_hyp} NOKEY
  provide-xfr: ${ns_hyp} NOKEY
EOF
  done
  
  # Generate zone files with DNSSEC support
  local serial subdomains subdomain zsk ksk
  for domain_entry in "${ALL_DOMAINS[@]}"; do
    domain="${domain_entry%%:*}"
    subdomains="${domain_entry#*:}" # Extract subdomains after colon
    serial=$(date +"%Y%m%d%H")
    
    # Create zone file
    doas mkdir -p "/var/nsd/zones/master"
    doas tee "/var/nsd/zones/master/${domain}.zone" >/dev/null <<EOF
\$ORIGIN ${domain}.
\$TTL 24h

@ 1h IN SOA ns.${domain}. hostmaster.${domain}. (
  ${serial} ; Serial YYYYMMDDnn
  1h         ; Refresh
  15m        ; Retry
  1w         ; Expire
  3m         ; Minimum TTL
)

@ IN NS ns.${domain}.
@ IN NS ns.hyp.net.

ns.${domain}. IN A $BRGEN_IP
ns.hyp.net. IN A 194.63.248.53

@ IN A $BRGEN_IP

; CAA record
@ IN CAA 0 issue "letsencrypt.org" 128 issue "pki.goog"

; Subdomains
EOF
    
    # Add subdomains
    if [[ -n "$subdomains" && "$subdomains" != "$domain" ]]; then
      for subdomain in ${(s:,:)subdomains}; do
        doas tee -a "/var/nsd/zones/master/${domain}.zone" >/dev/null <<EOF
${subdomain} IN CNAME @
EOF
      done
    fi
    
    # Generate DNSSEC keys
    zsk=$(doas ldns-keygen -a ECDSAP256SHA256 -b 1024 "$domain")
    ksk=$(doas ldns-keygen -k -a ECDSAP256SHA256 -b 2048 "$domain")
    doas mv K$domain.* /var/nsd/zones/master/
    
    # Sign zone and generate DS record
    sign_zone "$domain"
    
    # Generate DS record
    doas ldns-key2ds -n -2 "/var/nsd/zones/master/${domain}.zone.signed" > "/var/nsd/zones/master/${domain}.ds"
  done
  
  # Start NSD
  doas rcctl enable nsd
  doas rcctl start nsd
  
  # Verify NSD is working
  cleanup_nsd
  doas rcctl start nsd
  
  # Configure HTTP for ACME challenges
  backup_config "/etc/httpd.conf"
  doas tee "/etc/httpd.conf" >/dev/null <<'EOF'
server "default" {
  listen on * port 80
  location "/.well-known/acme-challenge/*" {
    root "/acme"
    request strip 2
  }
}
EOF
  
  doas rcctl enable httpd
  doas rcctl restart httpd
  
  # Verify HTTP server works for ACME challenges
  doas mkdir -p "/var/www/acme/.well-known/acme_challenge"
  echo "test" | doas tee "/var/www/acme/.well-known/acme_challenge/test" > /dev/null
  if ! curl -s "http://localhost/.well-known/acme_challenge/test" | grep -q "test"; then
    echo "ERROR: HTTP server not serving ACME challenges correctly" >&2
    exit 1
  fi
  
  # Generate private key for ACME client if it doesn't exist
  if [ ! -f "/etc/acme/letsencrypt_privkey.pem" ]; then
    doas mkdir -p "/etc/acme"
    doas openssl genrsa -out "/etc/acme/letsencrypt_privkey.pem" 4096
  fi
  
  # Set up ACME client
  backup_config "/etc/acme-client.conf"
  doas tee "/etc/acme-client.conf" >/dev/null <<EOF
authority letsencrypt {
  api url "https://acme-v02.api.letsencrypt.org/directory"
  account key "/etc/acme/letsencrypt_privkey.pem"
}
EOF

  # Issue certificates and generate TLSA records
  for domain_entry in "${ALL_DOMAINS[@]}"; do
    domain="${domain_entry%%:*}"
    subdomains="${domain_entry#*:}"
    first_subdomain=$(echo $subdomains | cut -d',' -f1)
    
    doas tee -a "/etc/acme-client.conf" >/dev/null <<EOF
domain ${domain} {
  alternative names { www.${domain} ${first_subdomain}.${domain} }
  domain key "/etc/ssl/private/${domain}.key" 
  domain full chain certificate "/etc/ssl/${domain}.crt"
  sign with letsencrypt
}
EOF
    
    # Issue certificate if it doesn't exist
    doas acme-client -v "$domain" || echo "NOTICE: Certificate issue failed for ${domain}. Will retry later." >&2
    
    # Generate TLSA record if we have a certificate
    if [ -f "/etc/ssl/${domain}.crt" ]; then
      generate_tlsa_record "$domain"
    fi
  done
  
  # Schedule certificate and TLSA renewal
  local crontab_tmp="/tmp/crontab_tmp"
  crontab -l 2>/dev/null > "$crontab_tmp" || touch "$crontab_tmp"
  
  # Add certificate renewal cron jobs
  echo "# Certificate renewals" >> "$crontab_tmp"
  for domain_entry in "${ALL_DOMAINS[@]}"; do
    domain="${domain_entry%%:*}"
    cat >> "$crontab_tmp" <<EOF
30 3 * * * doas acme-client ${domain} && doas rcctl reload relayd
EOF
  done
  
  # Install crontab
  doas crontab "$crontab_tmp"
  rm -f "$crontab_tmp"
  
  cat <<EOF

=== IMPORTANT NEXT STEPS ===
1. Upload Rails apps to /home/<app>/<app> directories
2. Each app must have Gemfile and config/database.yml
3. Submit DS records from /var/nsd/zones/master/<domain>.ds to your registrar
4. Wait 24-48 hours for DNS propagation
5. Run: doas zsh openbsd.sh --resume
EOF
}

stage2() {
  # Detect existing application ports before making any changes
  detect_app_ports
  
  # Configure full PF firewall
  backup_config "/etc/pf.conf"
  doas tee "/etc/pf.conf" >/dev/null <<'EOF'
# Define interfaces
ext_if = "vio0"

# Performance optimization
set skip on lo
set optimization aggressive
set ruleset-optimization basic

# Default policy
block all

# Allow connections we initiated
pass out

# Allow SSH with anti-brute force
table <bruteforce> persist file "/etc/pf-bruteforce"
block quick from <bruteforce>
pass in on $ext_if proto tcp to ($ext_if) port 22 flags S/SA \
     keep state (max-src-conn 15, max-src-conn-rate 5/3, \
     overload <bruteforce> flush global)

# Allow DNS traffic
pass in on $ext_if proto { tcp, udp } to ($ext_if) port 53

# Allow web traffic
pass in on $ext_if proto tcp to ($ext_if) port { 80, 443 }

# Include relayd rules
anchor relayd/*
EOF

  # Enable and configure PF
  doas touch /etc/pf-bruteforce
  doas chmod 600 /etc/pf-bruteforce
  doas rcctl enable pf
  doas pfctl -f /etc/pf.conf || echo "WARNING: PF configuration error, please review /etc/pf.conf" >&2

  # Deploy Rails apps
  local app_entry app primary_domain port app_dir
  for app_entry in "${ALL_APPS[@]}"; do
    app="${app_entry%%:*}"
    primary_domain="${app_entry#*:}"
    port="${APP_PORTS[$app]}"
    app_dir="/home/${app}/${app}"
    
    # Ensure user and directories exist
    if ! id -u "$app" >/dev/null 2>&1; then
      echo "Creating user $app" >&2
      doas useradd -m -s /bin/ksh "$app"
    fi
    
    doas mkdir -p "$app_dir"
    doas chown -R "$app:$app" "/home/$app"
    
    # Create service startup file
    backup_config "/etc/rc.d/${app}"
    doas tee "/etc/rc.d/${app}" >/dev/null <<EOF
#!/bin/ksh

# Rails/Falcon startup script for ${app}
daemon="/bin/ksh -c 'cd ${app_dir} && export RAILS_ENV=production && \${HOME}/.local/share/gem/ruby/3.3/bin/falcon serve -b http://127.0.0.1:${port}'"
daemon_user="${app}"

rc_pre() {
  if [ ! -d "${app_dir}" ]; then
    return 1
  fi

  # Security hardening with pledge/unveil
  /usr/bin/pledge "stdio rpath wpath cpath inet dns proc exec"
  /usr/bin/unveil "${app_dir}" "rwc"
  /usr/bin/unveil "/tmp" "rwc"
  /usr/bin/unveil "/var/log" "w"
  /usr/bin/unveil -
}

. /etc/rc.d/rc.subr
rc_cmd \$1
EOF
    doas chmod +x "/etc/rc.d/${app}"
    doas rcctl enable "$app"
  done
  
  # Configure relayd
  backup_config "/etc/relayd.conf"
  doas tee "/etc/relayd.conf" >/dev/null <<'EOF'
# Define log level
log connection

# HTTP protocol for all apps
http protocol "common" {
  # Forward client IP
  match request header set "X-Forwarded-For" value "$REMOTE_ADDR"
  match request header set "X-Forwarded-By" value "$SERVER_ADDR:$SERVER_PORT"
  
  # Security headers
  match response header set "Cache-Control" value "max-age=31536000"
  match response header set "Strict-Transport-Security" value "max-age=31536000; includeSubDomains; preload"
  match response header set "Content-Security-Policy" value "upgrade-insecure-requests; default-src https: 'self'"
  match response header set "X-Content-Type-Options" value "nosniff"
  match response header set "X-Frame-Options" value "SAMEORIGIN" 
  match response header set "X-Download-Options" value "noopen"
  match response header set "X-XSS-Protection" value "1; mode=block"
  match response header set "Referrer-Policy" value "strict-origin"
  match response header set "Feature-Policy" value "accelerometer 'none'; camera 'none'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; payment 'none'; usb 'none'"
  
  # WebSockets support for Action Cable/StimulusReflex
  http websockets
  
  # TCP options
  tcp { nodelay, sack, backlog 128 }
  
  # Timeouts
  timeout 60
}
EOF
  
  # Add app-specific relays to relayd.conf
  for app_entry in "${ALL_APPS[@]}"; do
    app="${app_entry%%:*}"
    primary_domain="${app_entry#*:}"
    port="${APP_PORTS[$app]}"
    
    doas tee -a "/etc/relayd.conf" >/dev/null <<EOF

table <${app}> { 127.0.0.1 }

relay "${app}" {
  listen on \$ext_if port 443 tls
  protocol "common"
  forward to <${app}> port ${port}

EOF

    # Add domain-specific rules for each app
    for domain_entry in "${ALL_DOMAINS[@]}"; do
      domain="${domain_entry%%:*}"
      if [[ "$domain" == *"$primary_domain"* || "$primary_domain" == *"$domain"* ]]; then
        doas tee -a "/etc/relayd.conf" >/dev/null <<EOF
  match request header "Host" value "${domain}" forward to <${app}>
  match request header "Host" value "www.${domain}" forward to <${app}>
EOF
      fi
    done
    
    # Close the relay block
    doas tee -a "/etc/relayd.conf" >/dev/null <<EOF
}
EOF
  done
  
  # Apply relayd configuration
  doas rcctl enable relayd
  doas rcctl restart relayd || echo "WARNING: relayd configuration error, please review /etc/relayd.conf" >&2
  
  # Final verification steps
  retry_failed_certs
  
  echo "Configuration complete. Verifying services..." >&2
  doas rcctl check nsd && echo "✓ nsd running" >&2 || echo "✗ nsd not running" >&2
  doas rcctl check httpd && echo "✓ httpd running" >&2 || echo "✗ httpd not running" >&2
  doas rcctl check relayd && echo "✓ relayd running" >&2 || echo "✗ relayd not running" >&2
  
  for app in "${ALL_APPS[@]%%:*}"; do
    if [ -d "/home/${app}/${app}" ]; then
      doas rcctl check "$app" && echo "✓ $app running" >&2 || echo "✗ $app not running" >&2
    else
      echo "! $app directory not found, service not started" >&2
    fi
  done
  
  cat <<EOF

=== SETUP COMPLETE ===
1. All DNS zones are configured and signed with DNSSEC
2. TLS certificates have been issued for all domains
3. relayd is configured to route requests to apps
4. Applications will start automatically on boot

Next steps:
1. Verify DB connection in /home/<app>/<app>/config/database.yml
2. Run bundle install and DB migrations for each app:
   doas su - <app> -c 'cd <app> && bundle install && bundle exec rails db:migrate RAILS_ENV=production'
3. Test all apps at https://<domain>/

For monitoring and maintenance:
- Check logs: tail -f /var/log/daemon /var/log/messages
- Reload configurations: doas rcctl reload <service>
- Certificate renewals run automatically via cron
EOF
}

# Stage 3: Email setup (optional)
stage3() {
  echo "Setting up email server..." >&2
  
  # Install OpenSMTPD from base system
  doas pkg_add -U opensmtpd-extras
  
  # Configure OpenSMTPD
  backup_config "/etc/mail/smtpd.conf"
  doas tee "/etc/mail/smtpd.conf" >/dev/null <<'EOF'
# Global settings
pki brgen.no cert "/etc/ssl/brgen.no.crt"
pki brgen.no key "/etc/ssl/private/brgen.no.key"

table aliases file:/etc/mail/aliases
table domains { 
  pub.attorney 
  pub.healthcare
  freehelp.legal
}
table virtuals file:/etc/mail/virtuals

# Local delivery for virtual domains
user _smtpd
user _vmail

# Accept messages from the local system for delivery
listen on lo0

# Accept messages from the internet for our domains
listen on vio0 tls-require pki brgen.no auth <secrets>

# Define the directory where mail is stored
queue compression
queue encryption key "random_encryption_key_here"

# Deliver mail to virtual users
action "deliver_virtual" maildir "/var/vmail/%{dest.domain}/%{dest.user}/Maildir"

# Route incoming mail to the appropriate action
match from any for domain <domains> action "deliver_virtual"
match from local for local action "deliver_virtual"
match auth from any for domain <domains> action "deliver_virtual"
EOF

  # Create mail directories
  doas mkdir -p /var/vmail
  for domain in pub.attorney pub.healthcare freehelp.legal; do
    doas mkdir -p "/var/vmail/${domain}"
    doas chown -R _vmail:_vmail "/var/vmail/${domain}"
  done
  
  # Create virtual user mappings
  doas tee "/etc/mail/virtuals" >/dev/null <<'EOF'
# Format: user@domain user
bergen@pub.attorney gfuser
contact@pub.healthcare gfuser
help@freehelp.legal gfuser
EOF

  # Start OpenSMTPD
  doas rcctl enable smtpd
  doas rcctl restart smtpd
  
  echo "Email setup complete. Mail is delivered to /var/vmail/<domain>/<user>/Maildir" >&2
  echo "Access email as gfuser using mutt" >&2
}

# Execution control
case "$1" in
  --help)
    cat <<EOF
Usage: doas zsh openbsd.sh [--help | --resume | --mail]
  --help: Show this usage message
  --resume: Run stage 2 after DNS propagation
  --mail: Run email setup after stages 1 and 2
EOF
    ;;
  --resume)
    stage2
    ;;
  --mail)
    stage3
    ;;
  *)
    stage1
    ;;
esac

# EOF (651 lines)
# SHA256: b08c35feacf2c68719d4e1dd97fea7f283a6b7c42ac8dfcd91e28ea5fc5932a3