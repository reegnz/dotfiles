mitmproxy_env_enable() {
    # TODO: make OS agnostic, right now only works on MacOS
    echo "Looking for openssl cert bundle..." >&2
    local cert_file="$($(brew ls openssl@1.1 | grep bin/openssl) version -d | cut -d'"' -f2)/cert.pem"
    export HTTP_PROXY="http://127.0.0.1:8080"
    export HTTPS_PROXY="http://127.0.0.1:8080"
    # JAVA
    # Java doesn't respect the HTTP_PROXY and HTTPS_PROXY environment variables, but it is
    # still possible to have it use a proxy.
    # It is also possible for java to use the MacOS Keychain directly.
    export JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStoreType=KeychainStore"
    export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Dhttp.proxyHost=localhost -Dhttp.proxyPort=8080"
    export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Dhttps.proxyHost=localhost -Dhttps.proxyPort=8080"
    # For tools not using Keychain
    # The python requests library doesn't respect the Keychain, so
    # you need to have it using openssl cert.pem bundle instead.
    export REQUESTS_CA_BUNDLE="$cert_file"
    # AWS CLI also doesn't use the keychain so have it use openssl certs.pem instead.
    export AWS_CA_BUNDLE="$cert_file"


    echo "Using openssl cert bundle: $cert_file"
    echo "Using proxy: $HTTP_PROXY"
}

mitmproxy_env_disable() {
    unset HTTP_PROXY HTTPS_PROXY JAVA_TOOL_OPTIONS REQUESTS_CA_BUNDLE AWS_CA_BUNDLE
}

mitmproxy_add_trust() { 
    if security find-certificate \
	-c mitmproxy \
	-p /Library/Keychains/System.keychain >/dev/null 2>&1; then
	sudo security delete-certificate \
	    -c mitmproxy /Library/Keychains/System.keychain
	echo "Removed existing mitmproxy certificate from system keychain." >&2
    fi
    sudo security add-trusted-cert \
	-d -p ssl -p basic \
	-k /Library/Keychains/System.keychain \
	"$XDG_HOME/.mitmproxy/mitmproxy-ca-cert.pem"

    # re-generate openssl certificate bundle from system keychain
    if brew ls --versions openssl@1.1; then
	brew postinstall openssl@1.1
    fi
    echo "Added mitmproxy certificate to system keychain." >&2
}


