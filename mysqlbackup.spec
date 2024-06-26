Name:           mysqlbackup
Version:        1.0.0
Release:        1%{?dist}
Summary:        Scripts, config and timers for backing up a DB

License:        MIT
Source0:        mysqlbackup-%{version}.tar.bz2

BuildRequires: systemd-rpm-macros
BuildRequires: make
Requires:      mariadb systemd pbzip2

%description
Scripts that perform mysqlbackups on a schedule

%prep
%autosetup

%install
export SYSTEMD_UNIT_DIR=%_unitdir SYSCONFIG_DIR=%{_sysconfdir}/sysconfig
%make_install

%post
%systemd_post %{name}.timer
%systemd_post %{name}.service

%preun
%systemd_preun %{name}.timer
%systemd_preun %{name}.service


%files
%license LICENSE
%doc README.md
%dir %{_sysconfdir}/mysqlbackup
%dir %{_sysconfdir}/mysqlbackup.d
%config(noreplace) %{_sysconfdir}/mysqlbackup/my.cnf
%{_sysconfdir}/sysconfig/mysqlbackup
/usr/sbin/mysqlbackup
%_unitdir/mysqlbackup.*

%changelog
* Wed Jun 26 2024 Nathanael d. Noblet <nathanael@noblet.ca>
- Initial release
