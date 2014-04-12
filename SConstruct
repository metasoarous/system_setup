#!/usr/bin/env python
import re
import os
import functools as fn
import subprocess as sp

import SCons
from SCons.Environment import Environment
from SCons.Script.Main import AddOption, GetOption


ubuntu_version = sp.check_output(['sh', '-c', 'lsb_release -a | grep Description']).split()[-1]
ubuntu_major, ubuntu_minor = map(int, ubuntu_version.split('.'))


AddOption("--strict", action="store_true",
    help="""Quit if a package doesn't doesn't install? By default we just raise warnings.""")
strict = GetOption("strict")


env = Environment(ENV=os.environ)
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
        sp.check_call(['sudo', 'apt-add-repository', 'ppa:%s' % p])
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
#spotify_rep = env.Command("/etc/apt/sources.list.d/spotify.list", [],
    #"sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59 && "
    #"sudo sh -c 'echo \"deb http://repository.spotify.com stable non-free\" > $TARGET'")

# XXX - hmm... this is a little stubborn... needs to be removed if already exists
# Add google talk repository so we can manage with apt-get
google_talk_rep = env.Command("/etc/apt/sources.list.d/google-talkplugin.list", [],
    "wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && "
    "sudo sh -c 'echo \"deb http://dl.google.com/linux/talkplugin/deb/ stable main\" > $TARGET'")
    #"sudo echo 'deb http://dl.google.com/linux/talkplugin/deb/ stable main' >> $TARGET")

# Update aptitude based on added ppas and repositories
#apt_update = env.Command("touches/apt-update", [ppas, spotify_rep, google_talk_rep],
apt_update = env.Command("touches/apt-update", [ppas, google_talk_rep],
    "sudo apt-get update > $TARGET")

# Starting a list of things we want to finish before doing apt install
apt_depends = [apt_update]

# Depends on Ubuntu 14.04 or later; should set a switch for this
if ubuntu_major > 13:
    apt_progress_bar = env.Command("/etc/apt/apt.conf.d/99progressbar", [],
        "sudo echo 'Dpkg::Progress-Fancy \"1\";' > $TARGET")
    # add to depends list
    apt_depends.append(apt_progress_bar)

# Install all repositories
apts = env.Command("touches/apts", "lists/apt_list", apt_install)
env.Depends(apts, apt_depends) # make sure this stuff runs after update

# Install mendeley
if not package_exists('mendeleydesktop'):
    mendeley = env.Command("touches/mendeley", [],
        "sudo dpkg -i http://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest")
else:
    mendeley = []

# Install RVM if not present; set 2.1 as default; install some standard useful gems
rvm = env.Command("touches/rvm", [], 'setup_rvm.sh && touch $TARGET')

# Install pathogen and standard vim plugins
pathogen = env.Command("$HOME/.vim/bundle", [apts], "./install_pathogen.sh")

# Install default python packages
python_pkgs = env.Command("touches/python_pkgs", ["lists/requirements.txt", apts],
    "pip install -r $SOURCE && "
    "date > $TARGET")

# Install R packages
r_pkgs = env.Command("touches/r_pkgs", [apts], "install_packages.R && date > $TARGET")

# dotfiles :-)
dotfiles = env.Command("$HOME/.dotfiles", [rvm, apts],
    "git clone git@github.com:metasoarous/dotfiles.git $TARGET && "
    "cd $TARGET && "
    "rake backup && "
    "rake install")

# lein profile - need to hook this in with the dotfiles, so this can dep onthat
# encaps: epkg, copy, gnome-terminal-colors-solarized, processing-2.0.1, sequin, Tracer_v1.5 

