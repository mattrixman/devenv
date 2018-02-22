#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PWD="$(pwd)"

deploy="$DIR/deploy"
sm_bs_dir="$DIR/billing-server"
fs_bs_dir="$DIR/billing-server_copy"

usage() { 
    echo "Usage: $0 [-vh] {  -g <billing-server_git_SHA1> "
    echo "                | -l local-billing-server-repo-root"
    echo "                | -a billing_server_artifact_hash } " 
    echo ""
    echo "   -h help"
    echo "   -v verbose"
    echo ""
    echo "   -g will clobber $sm_bs_dir with the specified tree-ish from phabricator"
    echo "   -l will clobber $fs_bs_dir with the contents of the specified folder"
    echo "   -a will unpack the specified artifact into $deploy"
    echo ""
    echo "  If -g, -l, or -a are specified, the needed binaries will be placed in $deploy" 
}

if [[ $# -eq "0" ]] ; then
    usage
    exit 0
fi

# if verbose is set, this will have -v
vflag=""

# if building is required, this will point to the repo root
build_dir=""

# if required options are present, this will be true
go=0

while getopts "vhg:l:a:" options; do
    case $options in
        v ) set -x
            vflag="-v"
        ;;
        g ) billing_server_gsha=$OPTARG
            build_dir=$sm_bs_dir
            cd $sm_bs_dir
            git clean -dfx
            git reset --hard
            git pull origin $billing_server_gsha
            go=1
        ;;
        l ) local_repo=$OPTARG
            build_dir=$fs_bs_dir/billing-server
            rsync $vflag -ar $local_repo $fs_bs_dir
            go=1
        ;;
        a) url="http://artifactory.corp.clover.com:8081/artifactory/ext-release-local/com/clover/billing-server/dev/billing/${OPTARG}/billing-${OPTARG}.tar"
           tarname=$(basename "$url")
           [[ ! -f $tarname ]] && wget "$url"
           rm $vflag -rf $deploy
           mkdir $vflag $deploy
           tar $vflag -xf $tarname -C $deploy
        ;;
        h ) usage $$ exit 0
            go=1
        ;;
    esac
done


# if sufficient parameters for deploying were specified
if [[ $go -ne "0" ]] ; then

    # if we need to build the artifact, do so
    if [[ -d $build_dir ]] ; then
        cd $vflag $build_dir/billing-server
        mvn clean install -DskipTests

        # put build outputs in $deploy
        rsync $vflag -ar ./target $deploy
    fi

    echo Deploy prerequisites are now in $deploy
fi



cd $PWD
