Name:           
Version:        1.0
Release:        1%{?dist}
Summary:        Dummy test package

Group:          Development/Debug
License:        Public Domain
URL:            http://fedoraproject.org/

%description


%prep


%build


%install
rm -rf $RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)


%changelog
