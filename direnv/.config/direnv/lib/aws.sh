use_aws_profile() {
	export AWS_PROFILE=$1
	export AWS_REGIONAL_ENDPOINTS="regional"
}

use_aws_region() {
	export AWS_DEFAULT_REGION=$1
}

use_eks_cluster() {
	KUBECONFIG="$(direnv_layout_dir)/aws_eks/$1.yaml"
	export KUBECONFIG
	if [ ! -f "$KUBECONFIG" ]; then
		aws eks update-kubeconfig --name "$1" >&2
	fi
}
