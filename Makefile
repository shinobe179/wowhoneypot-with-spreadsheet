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

delete-honeypot:
	@systemctl disable --now WOWHoneypot.service
	@rm /etc/systemd/system/WOWHoneypot.service
	@systemctl daemon-reload
	@rm /etc/logrotate.d/WOWHoneypot
	@rm -rf /opt/WOWHoneypot

delete-watcher:
	@systemctl disable --now honeypot-watcher.service
	@rm /etc/systemd/system/honeypot-watcher.service
	@systemctl daemon-reload
	@rm -rf /opt/honeypot-watcher

delete-iptables:
	@echo "[NOTE}Please delete the rule by yourself."
	@echo "[NOTE}e.g. sudo iptables -nL --line-numbers -t nat"
	@echo "[NOTE}e.g. sudo iptables -t nat -D PREROUTING {number}"
	@echo "[NOTE}e.g. sudo service iptables save"
	@echo "[NOTE}e.g. sudo systemctl restart iptables"

delete-init:
	@userdel honeypotter

delete-all:
	@make delete-honeypot
	@make delete-watcher
	@make delete-iptables
	@make delete-init


reset:
	@make delete-all
	@make run
