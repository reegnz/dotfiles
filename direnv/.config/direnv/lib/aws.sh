use_aws_profile() {
	export AWS_PROFILE=$1
}

use_eks_cluster() {
	KUBECONFIG="$(direnv_layout_dir)/k8s/kubeconfig.yaml"
	export KUBECONFIG
	if [ ! -f "$KUBECONFIG" ]; then
		aws eks update-kubeconfig --name "$1" >&2
	fi
}
