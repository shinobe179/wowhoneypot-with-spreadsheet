run:
	@make init
	@make honeypot
	@make watcher
	@make iptables

init:
	@adduser honeypotter --no-create-home --shell /sbin/nologin --uid 41832

honeypot:
	@cp -rp ./WOWHoneypot /opt/WOWHoneypot
	@touch /opt/WOWHoneypot/log/access_log
	@chown -R honeypotter:honeypotter /opt/WOWHoneypot
	@cp -p ./logrotate.d/WOWHoneypot /etc/logrotate.d/WOWHoneypot
	@chmod 644 /etc/logrotate.d/WOWHoneypot
	@cp -p ./systemd/WOWHoneypot.service /etc/systemd/system/WOWHoneypot.service
	@systemctl daemon-reload
	@systemctl enable --now WOWHoneypot.service

watcher:
	@cp -rp ./honeypot-watcher /opt/honeypot-watcher
	@chmod 600 /opt/honeypot-watcher/client_secret.json
	@chown -R honeypotter:honeypotter /opt/honeypot-watcher
	@pip3 install pygtail gspread oauth2client
	@cp -p ./systemd/honeypot-watcher.service /etc/systemd/system/honeypot-watcher.service
	@systemctl daemon-reload
	@systemctl enable --now honeypot-watcher.service
	@echo "[NOTE] If valid client_secret.json is not set in /opt/honeypot-watcher, honeypot-watcher.service will be failed soon."
	@echo "[NOTE] Please set up Google Cloud Sheet and Drive API, put client_secret.json in /opt/honeypot-watcher, and restart the service."

iptables:
	@yum -y install iptables-services
	@systemctl enable --now iptables.service
	@iptables -F
	@iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
	@service iptables save
	@systemctl enable --now iptables

