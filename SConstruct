#!/usr/bin/env python
import re
import os
import functools as fn
import subprocess as sp
from os import path

import SCons
from SCons.Environment import Environment
from SCons.Script.Main import AddOption, GetOption


ubuntu_version = sp.check_output(['sh', '-c', 'lsb_release -a | grep Release']).split()[-1]
ubuntu_codename = sp.check_output(['sh', '-c', 'lsb_release -a | grep Codename']).split()[-1]
ubuntu_major, ubuntu_minor = map(int, ubuntu_version.split('.'))

hostname = sp.check_output(['hostname']).split()[0]
db_public = "https://dl.dropboxusercontent.com/u/13117378/"


AddOption("--strict", action="store_true",
    help="""Quit if a package doesn't doesn't install? By default we just raise warnings.""")
strict = GetOption("strict")

class SysSetupEnv(Environment):
    def SudoCommand(self, target, source, action, **kw_args):
        alias = kw_args.pop('alias', None)
        def sudo_action(target, source, env):
            print "Calling sudo with the following action:\n", action
            sp.check_output(['sudo', 'sh', '-c', action])
        tgt = super(SysSetupEnv, self).Command(target, source, sudo_action, **kw_args)
        if alias:
            Alias(alias, tgt)
        return tgt



vars = Variables()
vars.Add('HOME', default=os.environ['HOME'])
env = SysSetupEnv(variables=vars, ENV=os.environ)
for p in ['/usr/local/bin', './bin']:
    env.PrependENVPath('PATH', p)


class MissingPackageException(Exception):
    pass

strip_comments = fn.partial(re.sub, "\#.*", "")

def safe_get_filename(fileish):
    fileish = fileish[0] if isinstance(fileish, list) else fileish
    return fileish.path if isinstance(fileish, SCons.Node.FS.File) else fileish

def safe_get_file(fileish, mode='r'):
    return file(safe_get_filename(fileish), mode)

def get_list(list_file, exist_fn=lambda x: x):
    exist, missing = [], []
    for line in safe_get_file(list_file):
        line = strip_comments(line)
        line = line.strip()
        if line:
            append_to = exist if exist_fn(line) else missing
            append_to.append(line)
    return exist, missing

def package_exists(pkg_name):
    res = sp.check_output(["apt-cache", "showpkg", pkg_name])
    # This seems to work even though it shouldn't...
    return res and res.split('\n')[2]
    #line1 = res.split("\n")[0]
    #return not re.search("Unable to locate", line1)

def ppa_install(target, source, env):
    exist, missing = get_list(source)
    f = safe_get_file(target, "w")
    for p in exist:
        print "You will have to hit enter here... for now"
        sp.check_call(['sudo', 'apt-add-repository', '-y', 'ppa:%s' % p])
        sp.check_call(['date'], stdout=f)

def apt_install(target, source, env):
    exist, missing = get_list(source, package_exists)
    #import pdb; pdb.set_trace()
    # Using this version gives us our slick progress bar!
    apt_command = "apt" if ubuntu_major > 13 else "apt-get"
    if missing and strict:
        raise MissingPackageException("missing the following packages: %s" % missing)
    else:
        f = safe_get_file(target, "w")
        call = ["sudo", apt_command, '-y']
        if not strict:
            call.append('-m')
        sp.check_call(call + ["install"] + exist)
    sp.check_call(['date'], stdout=f)


# Add required ppas and other repositories
ppas = env.Command("touches/ppas", "lists/ppa_list", ppa_install)

# Add spotify repository so we can manage with apt-get
spotify_rep = env.Command(["/etc/apt/sources.list", "touches/spotify_rep"], [],
    "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59 && "
    "sudo sh -c 'echo \"deb http://repository.spotify.com stable non-free\" >> $TARGET' && "
    "date > ${TARGETS[1]}")
env.Precious(spotify_rep)

# XXX - hmm... this is a little stubborn... needs to be removed if already exists
# Add google talk repository so we can manage with apt-get
google_talk_rep = env.Command("/etc/apt/sources.list.d/google-talkplugin.list", [],
    "wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && "
    "sudo sh -c 'echo \"deb http://dl.google.com/linux/talkplugin/deb/ stable main\" > $TARGET'")
    #"sudo echo 'deb http://dl.google.com/linux/talkplugin/deb/ stable main' >> $TARGET")

# Add latest R repo, but only if version is less than 14, since 14 cran isn't up and has R recent enough for
# hadleyverse
if ubuntu_major < 14:
    r_edge_rep = env.Command("/etc/apt/sources.list", [],
        "sudo sh -c 'echo \"deb http://cran.fhcrc.org/bin/linux/ubuntu %s/\" >> $TARGET'" % ubuntu_codename)
    env.Precious(r_edge_rep)
else:
    r_edge_rep = []

# Update aptitude based on added ppas and repositories
# XXX - should really change to date
apt_update = env.Command("touches/apt-update", [ppas, spotify_rep, google_talk_rep, r_edge_rep],
    "sudo apt-get update && touch $TARGET")

# These require interaction so we put them first and make other apt installs depend
# there is some other package that depends on the true type fonts... maybe it was silverlight?
inter_apts = env.SudoCommand("touches/inter_apts", apt_update, "apt-get install gnome-shell")
# Install and activate silverlight plugin (make sure browser is off)
silverlight = env.Command("touches/silverlight", apts,
    "sudo apt-get --install-recommends pipelight-multi && "
    "sudo pipelight-plugin --enable silverlight && "
    "date > $TARGET")
# Starting a list of things we want to finish before doing apt install
apt_depends = [apt_update, inter_apts, silverlight]


# Depends on Ubuntu 14.04 or later; should set a switch for this
if ubuntu_major > 13:
    apt_progress_bar = env.Command("/etc/apt/apt.conf.d/99progressbar", [],
        "sudo sh -c 'echo \"Dpkg::Progress-Fancy '1';\" > $TARGET'")
    # add to depends list
    apt_depends.append(apt_progress_bar)

# Install all repositories
apts = env.Command("touches/apts", "lists/apt_list", apt_install)
env.Depends(apts, apt_depends) # make sure this stuff runs after update

# Active pepper flash for chromium
pepper_flash = env.Command("touches/pepperflash", apts,
    "sudo update-pepperflash-nonfree --install && "
    "date > $TARGET")

# Install mendeley
if package_exists('mendeleydesktop'):
    mendeley = env.Command("touches/mendeley", [],
        "sudo dpkg -i http://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest")
else:
    mendeley = []

# Install RVM if not present; set 2.1 as default; install some standard useful gems
rvm = env.Command("touches/rvm", [], 'setup_rvm.sh && date > $TARGET')

# Install pathogen and standard vim plugins
pathogen = env.Command("$HOME/.vim/bundle", [apts], "install_pathogen.sh")
Alias("pathogen", pathogen)

# Install default python packages
python_pkgs = env.Command("touches/python_pkgs", ["lists/requirements.txt", apts],
    "sudo pip install -r $SOURCE && "
    "date > $TARGET")
Alias("python", python_pkgs)

# Install R packages
r_pkgs = env.Command("touches/r_pkgs", [apts], "sudo ./bin/install_packages.R && date > $TARGET")

# dotfiles :-)
# Have to use http unless you upload certs first; pain in ass
# Add mkdir for ./bin/ in dotfiles; also default build
dotfiles = env.Command("$HOME/.dotfiles", [rvm, apts],
    #"git clone git@github.com:metasoarous/dotfiles.git $TARGET && "
    "git clone https://github.com/metasoarous/dotfiles $TARGET && "
    "cd $TARGET && "
    "rake backup && "
    "mkdir -p $HOME/bin && "
    "rake install")
Alias("dotfiles", dotfiles)

# Radness
gnome_terminal_solarized = env.Command("$HOME/src/gnome-terminal-colors-solarized", [],
    "rm -rf $TARGET && "
    "git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git $TARGET && "
    "cd $TARGET && "
    "./install.sh")
# get to seldct dark by default
Alias("solarize", [gnome_terminal_solarized])

# Install dropbox
dropbox = env.Command("touches/dropbox", [],
    "curl https://linux.dropbox.com/packages/ubuntu/dropbox_1.6.0_amd64.deb > dropbox.deb && "
    "sudo dpkg -i dropbox.deb && "
    "rm dropbox.deb && "
    "echo 'Dropbox installed - youll want to run dropbox start -i from the terminal' && "
    "date > $TARGET")
Alias("dropbox", dropbox)

# There is a problem on fullerine with brightness not always working; this seems to fix it, at least in 14.04
if hostname == "fullerine":
    brightness_fix = env.Command("/usr/share/X11/xorg.conf.d/20-intel.conf",
        "files/brightness_fix.conf",
        "sudo sh -c 'cat $SOURCE > $TARGET'")
else:
    brightness_fix = []
Alias('brightness_fix', brightness_fix)


# Haven't tested if this works yet
epkg_link = "ftp://ftp.encap.org/pub/encap/epkg/epkg-2.3.9.tar.gz"
epkg = env.SudoCommand(["/usr/local/encap/epkg-2.3.9", "/usr/local/bin/epkg"], [apts],
    "mkdir -p /usr/local/encap && "
    "mkdir -p /usr/local/src && "
    "cd /usr/local/src && "
    "curl %s > src/epkg-2.3.9.tar.gz && "
    "zcat epkg-2.3.9.tar.gz | tar xvvpf - && "
    "cd epkg-2.3.9 && "
    "./configure --prefix=$TARGET && "
    "make && make install && cd $TARGET/.. && "
    "epkg-2.3.9/bin/epkg epkg" % epkg_link)


# make sure to have a clean for removing beast install
beast_version = "2.1.2"
beast_tar = "BEAST.v%s.tgz" % beast_version
beast_download = db_public + beast_tar
beast = env.SudoCommand(
    [path.join("/usr/local", x) for x in
        ["encap/BEAST-%s/" % beast_version] +
            [path.join("bin", x) for x in
                ["addonmanager", "beast", "beauti", "densitree", "logcombiner", "treeanotator"]]],
    [],
    ("cd /usr/local/encap && "
        "wget {beast_download} && "
        "tar -zxf {beast_tar} && "
        "mv BEAST beast-{beast_version} && "
        "epkg beast").format(beast_download=beast_download, beast_tar=beast_tar, beast_version=beast_version),
    alias="beast")

hub = env.Command("/usr/local/bin/hub", [rvm],
    "mkdir -p $HOME/src && cd $HOME/src/ && "
    "git clone git://github.com/github/hub.git && cd hub && "
    "sudo rake install")
Alias('hub', hub)

# Times in seconds - screensaver/lock; don't know if this works yet - XXX
screen_lock = env.Command("touches/screen_lock", [],
    "gsettings set org.gnome.desktop.session idle-delay 0 && "
    "gesttings set org.gnome.settings-daemon.plugins.power sleep-display-ac 1800 && "
    "gesttings set org.gnome.settings-daemon.plugins.power sleep-display-battery 500 && "
    "date > $TARGET")

# Copy cloud storage service
copyss = env.SudoCommand("touches/copyss", [apts],
    "cd /usr/local/encap && "
    "curl http://copy.com/install/linux/Copy.tgz | tar -zxf - && "
    "ln -s ../encap/copy/x86_64/Copy* ../bin/")
env.Alias("copy", copyss)


# Create an "all" alias for building everything
items = locals().values()
all_tgts = [tgt for tgt in Flatten(items) if isinstance(tgt, SCons.Node.FS.Entry)]
Alias('all', all_tgts)


# lein profile - need to hook this in with the dotfiles, so this can dep onthat
# encaps: epkg, copy, gnome-terminal-colors-solarized, processing-2.0.1, sequin, Tracer_v1.5, beast2

# Definitely set up gnome-terminal-solarized
# Do this stuff after installing crash plan - http://support.code43.com/CrashPlan/Latest/Troubleshooting/CrashPlan_Client_Closes_In_Some_Linux_Installations
# file type program defaults - gvim/vim for text, etc
# add vim and firefox spelling and merge all

