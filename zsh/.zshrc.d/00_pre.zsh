pathmunge() {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

unamestr="$(uname)"
case "$unamestr" in
	"Linux")
		platform="${unamestr:l}"
		;;
	"Darwin")
		platform="${unamestr:l}"
		;;
	*)
		platform="unknown"
		;;
esac
