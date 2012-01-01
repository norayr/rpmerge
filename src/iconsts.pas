unit iconsts;

interface
const prname = 'rpmerge';
const prver = '3.0.1';
const releasedate = '01/01/2012';
const conffile : string = '/etc/' + prname + '.conf';
const sources_data_file = 'sources';
const sources_data_file_footer : string = 'thats all folks';
const rpmbuildparams : string = ' --rebuild --target ';
const rpmbuilderror : string = 'error: Failed build dependencies:';
const rpmbuildmsg : string = 'Installing';
{const default_srpms_url : string = 'ftp://ftp.redhat.com/pub/redhat/linux/enterprise/4/en/os/i386/SRPMS/';
const default_srpms_url2 : string = 'http://download1.rpmfusion.org/nonfree/el/updates/testing/5/SRPMS/';
const default_srpms_url3 : string = 'http://download.fedora.redhat.com/pub/epel/4/SRPMS/';
const default_srpms_url4 : string = 'http://repo.redhat-club.org/redhat/5/SRPMS/';}
const http_prefix : string = 'http://';
const ftp_prefix : string = 'ftp://';
const srcrpmext : string = 'src.rpm';
const targzext : string = 'tar.gz';
const tarbzext : string = 'tar.bz2';
const srcrpmextlen : integer = 7;
const rpmbuilderrors : string = 'RPM build errors:';
const rpmothererrors : string = 'error:';
const devel : string = '-devel';
const usrbinpath : string = '/usr/bin/';
const debuginfo : string = '-debuginfo';
const rpminstall : string = 'rpm -iUvh --nodeps --force ';
const rpmqa : string = 'rpm -qa ';

implementation

end.
