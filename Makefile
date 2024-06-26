
NAME	= mysqlbackup
VERSION	= 1.0.1

#
#	Command to remove files, copy files and create directories.
#
#	I've never encountered a *nix environment in which these commands do not work. 
#	So you can probably leave this as it is
#

RM		=	rm -f
CP		=	cp -f
MKDIR	=	mkdir -p
SYSTEMD_UNIT_DIR=/usr/lib/systemd/system
SYSCONFIG_DIR=/etc/sysconfig

install:
	install -d -m 0750 $(DESTDIR)/etc/mysqlbackup
	install -d -m 0750 $(DESTDIR)/etc/mysqlbackup.d
	install -d -m 0755 $(DESTDIR)$(SYSCONFIG_DIR)
	install -d -m 0755 $(DESTDIR)$(SYSTEMD_UNIT_DIR)
	install -m 0644 mysqlbackup.timer $(DESTDIR)$(SYSTEMD_UNIT_DIR)
	install -m 0644 mysqlbackup.service $(DESTDIR)$(SYSTEMD_UNIT_DIR)
	install -D -m 0755 mysqlbackup.sh $(DESTDIR)/usr/sbin/mysqlbackup
	install -m 0640 mysqlbackup.sysconfig $(DESTDIR)$(SYSCONFIG_DIR)/mysqlbackup
	install -m 0640 my.cnf $(DESTDIR)/etc/mysqlbackup/

uninstall:
	rm $(DESTDIR)$(SYSTEMD_UNIT_DIR)/mysqlbackup.timer
	rm $(DESTDIR)$(SYSTEMD_UNIT_DIR)/mysqlbackup.service
	rm $(DESTDIR)$(SYSCONFIG_DIR)/mysqlbackup
	rm $(DESTDIR)/usr/sbin/mysqlbackup
	rm -rf $(DESTDIR)/etc/mysqlbackup
	rm -rf $(DESTDIR)/etc/mysqlbackup.d

dist: 
	tar --exclude-vcs-ignores --exclude-vcs --exclude=*tar.bz2 --transform 's,^\.,${NAME}-${VERSION},' -cjf ../${NAME}-${VERSION}.tar.bz2 .
	cp ../${NAME}-${VERSION}.tar.bz2 .
